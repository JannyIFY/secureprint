# SecurePrint

**Biometric Bitcoin Recovery System** - A distributed biometric data storage system for secure hardware wallet recovery using Stacks blockchain technology.

## Overview

SecurePrint enables secure Bitcoin wallet recovery through distributed biometric authentication. The system splits biometric data into encrypted shards stored across Stacks smart contracts, ensuring no single point of failure while maintaining user privacy and security.

## Key Features

- **Distributed Storage**: Biometric data is split into encrypted shards and distributed across the network
- **Threshold Recovery**: Configurable threshold system requiring only a subset of shards for recovery
- **Privacy-First**: All biometric data is encrypted before storage on-chain
- **Tamper-Resistant**: Blockchain immutability ensures data integrity
- **User-Controlled**: Users maintain full control over their biometric records

## How It Works

1. **Initialization**: User creates a biometric record with a specified recovery threshold
2. **Shard Storage**: Encrypted biometric data shards are stored across distributed nodes
3. **Recovery Process**: User provides required number of shards to initiate wallet recovery
4. **Verification**: System verifies authenticity and reconstructs access credentials

## Smart Contract Functions

### Setup Functions
- `initialize-biometric-record(threshold)` - Create new biometric record
- `store-biometric-shard(index, data, signature)` - Store encrypted biometric shard

### Recovery Functions
- `initiate-recovery(shard-list)` - Start recovery process with provided shards
- `is-recovery-possible(user-id)` - Check if recovery is possible for a user

### Management Functions
- `update-threshold(new-threshold)` - Modify recovery threshold
- `deactivate-biometric-record()` - Disable biometric record

### Query Functions
- `get-biometric-record(user-id)` - Retrieve user's biometric record
- `get-user-shard-count(user-id)` - Get number of stored shards

## Technical Specifications

- **Blockchain**: Stacks (Bitcoin Layer 2)
- **Smart Contract Language**: Clarity
- **Maximum Shards**: 10 per user
- **Minimum Threshold**: 2 shards
- **Encryption**: AES-256 (off-chain preprocessing)
- **Shard Size**: 512 bytes maximum

## Security Model

### Threat Mitigation
- **Single Point of Failure**: Eliminated through shard distribution
- **Biometric Theft**: Encrypted storage prevents raw biometric exposure
- **Replay Attacks**: Node signatures and timestamps prevent reuse
- **Unauthorized Access**: Smart contract permissions enforce user ownership

### Privacy Guarantees
- Raw biometric data never touches the blockchain
- Encrypted shards are computationally infeasible to reverse
- User identity is pseudonymous (Stacks addresses)
- Recovery attempts are logged but not linked to external identities

## Installation & Deployment

### Prerequisites
- Stacks CLI
- Clarinet (for testing)
- Node.js (for client applications)

### Deployment Steps
```bash
# Clone the repository
git clone https://github.com/your-org/secureprint.git
cd secureprint

# Install dependencies
npm install

# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

### Testing
```bash
# Run unit tests
clarinet test

# Run integration tests
npm run test:integration
```

## Usage Example

```clarity
;; Initialize biometric record with threshold of 3
(contract-call? .secureprint initialize-biometric-record u3)

;; Store biometric shards
(contract-call? .secureprint store-biometric-shard u0 encrypted-data-0 signature-0)
(contract-call? .secureprint store-biometric-shard u1 encrypted-data-1 signature-1)
(contract-call? .secureprint store-biometric-shard u2 encrypted-data-2 signature-2)

;; Initiate recovery with 3 shards
(contract-call? .secureprint initiate-recovery (list u0 u1 u2))
```

## API Integration

SecurePrint provides RESTful APIs for client applications:

- `POST /api/register` - Register new user
- `POST /api/store-shard` - Store biometric shard
- `POST /api/recover` - Initiate recovery process
- `GET /api/status/:userId` - Check recovery status

## Roadmap

- [ ] **v1.0**: Core biometric recovery functionality
- [ ] **v1.1**: Multi-signature recovery support
- [ ] **v1.2**: Hardware security module integration
- [ ] **v2.0**: Cross-chain compatibility (Ethereum, Polygon)
- [ ] **v2.1**: Mobile SDK for iOS/Android
- [ ] **v3.0**: Zero-knowledge proof implementation

## Contributing

We welcome contributions!

### Development Setup
```bash
git clone https://github.com/your-org/secureprint.git
cd secureprint
npm install
clarinet requirements
```

## Security Audits

- **Audit Firm**: [Pending]
- **Status**: In Progress
- **Report**: [Will be published upon completion]
