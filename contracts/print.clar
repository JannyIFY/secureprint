;; SecurePrint - Biometric Bitcoin Recovery System
;; A distributed biometric data storage system for hardware wallet recovery
;; using Stacks blockchain technology

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_BIOMETRIC_EXISTS (err u101))
(define-constant ERR_BIOMETRIC_NOT_FOUND (err u102))
(define-constant ERR_INVALID_THRESHOLD (err u103))
(define-constant ERR_INSUFFICIENT_SHARDS (err u104))
(define-constant ERR_SHARD_ALREADY_EXISTS (err u105))
(define-constant ERR_INVALID_SHARD_INDEX (err u106))

;; Data structures
(define-map biometric-records
  { user-id: principal }
  {
    total-shards: uint,
    threshold: uint,
    created-at: uint,
    last-updated: uint,
    is-active: bool
  }
)

(define-map biometric-shards
  { user-id: principal, shard-index: uint }
  {
    encrypted-data: (buff 512),
    node-signature: (buff 64),
    created-at: uint
  }
)

(define-map recovery-attempts
  { user-id: principal, attempt-id: uint }
  {
    timestamp: uint,
    shards-provided: uint,
    success: bool
  }
)

(define-data-var next-attempt-id uint u0)

;; Read-only functions
(define-read-only (get-biometric-record (user-id principal))
  (map-get? biometric-records { user-id: user-id })
)

(define-read-only (get-biometric-shard (user-id principal) (shard-index uint))
  (map-get? biometric-shards { user-id: user-id, shard-index: shard-index })
)

(define-read-only (get-recovery-attempt (user-id principal) (attempt-id uint))
  (map-get? recovery-attempts { user-id: user-id, attempt-id: attempt-id })
)

(define-read-only (get-user-shard-count (user-id principal))
  (match (get-biometric-record user-id)
    record (get total-shards record)
    u0
  )
)

(define-read-only (is-recovery-possible (user-id principal))
  (match (get-biometric-record user-id)
    record (and 
             (get is-active record)
             (>= (get total-shards record) (get threshold record)))
    false
  )
)

;; Private functions
(define-private (validate-threshold (total-shards uint) (threshold uint))
  (and (> threshold u0) (<= threshold total-shards) (>= total-shards u2))
)

;; Public functions
(define-public (initialize-biometric-record (threshold uint))
  (let ((user-id tx-sender))
    (asserts! (is-none (get-biometric-record user-id)) ERR_BIOMETRIC_EXISTS)
    (asserts! (validate-threshold u5 threshold) ERR_INVALID_THRESHOLD)
    
    (map-set biometric-records
      { user-id: user-id }
      {
        total-shards: u0,
        threshold: threshold,
        created-at: block-height,
        last-updated: block-height,
        is-active: true
      }
    )
    (ok true)
  )
)

(define-public (store-biometric-shard 
  (shard-index uint) 
  (encrypted-data (buff 512)) 
  (node-signature (buff 64)))
  (let (
    (user-id tx-sender)
    (record (unwrap! (get-biometric-record user-id) ERR_BIOMETRIC_NOT_FOUND))
  )
    (asserts! (get is-active record) ERR_UNAUTHORIZED)
    (asserts! (is-none (get-biometric-shard user-id shard-index)) ERR_SHARD_ALREADY_EXISTS)
    (asserts! (< shard-index u10) ERR_INVALID_SHARD_INDEX)
    
    ;; Store the shard
    (map-set biometric-shards
      { user-id: user-id, shard-index: shard-index }
      {
        encrypted-data: encrypted-data,
        node-signature: node-signature,
        created-at: block-height
      }
    )
    
    ;; Update the record
    (map-set biometric-records
      { user-id: user-id }
      (merge record { 
        total-shards: (+ (get total-shards record) u1),
        last-updated: block-height 
      })
    )
    
    (ok shard-index)
  )
)


(define-private (verify-shard-exists (shard-info { user: principal, index: uint }))
  (is-some (get-biometric-shard (get user shard-info) (get index shard-info)))
)

(define-public (deactivate-biometric-record)
  (let ((user-id tx-sender))
    (match (get-biometric-record user-id)
      record (begin
               (map-set biometric-records
                 { user-id: user-id }
                 (merge record { 
                   is-active: false,
                   last-updated: block-height 
                 })
               )
               (ok true))
      ERR_BIOMETRIC_NOT_FOUND
    )
  )
)

(define-public (update-threshold (new-threshold uint))
  (let (
    (user-id tx-sender)
    (record (unwrap! (get-biometric-record user-id) ERR_BIOMETRIC_NOT_FOUND))
  )
    (asserts! (get is-active record) ERR_UNAUTHORIZED)
    (asserts! (validate-threshold (get total-shards record) new-threshold) ERR_INVALID_THRESHOLD)
    
    (map-set biometric-records
      { user-id: user-id }
      (merge record { 
        threshold: new-threshold,
        last-updated: block-height 
      })
    )
    (ok true)
  )
)