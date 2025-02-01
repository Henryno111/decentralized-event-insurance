# Decentralized Event Insurance Smart Contract

[![Built with Clarity](https://img.shields.io/badge/Built%20with-Clarity-blue)](https://clarity-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen)]()

A decentralized event insurance platform built on the Stacks blockchain, enabling event organizers to offer insurance and attendees to protect their tickets through smart contracts.

## Features

* **Automated Insurance Processing**
  * Instant policy creation
  * Transparent premium calculations
  * Automated claims processing

* **Multi-Party Verification**
  * Weather oracle integration
  * Venue verification
  * Government authority validation

* **Flexible Coverage Options**
  * Configurable premium amounts
  * Adjustable participant limits
  * Customizable claim windows

## Technical Architecture

### Core Components

```
event-insurance/
├── contracts/
│   └── event-insurance.clar     # Main contract
├── tests/
│   └── event-insurance_test.ts  # Test suite
└── settings/
    └── Devnet.toml             # Network settings
```

### Contract Functions

#### Event Registration
```clarity
(contract-call? .event-insurance register-event 
    u1              ;; event-id
    u1000           ;; event-date
    u50000000       ;; premium-amount
    u100            ;; max-participants
)
```

#### Insurance Purchase
```clarity
(contract-call? .event-insurance purchase-insurance u1)
```

#### Event Cancellation
```clarity
(contract-call? .event-insurance cancel-event u1)
```

#### Insurance Claim
```clarity
(contract-call? .event-insurance claim-insurance u1)
```

## Getting Started

### Prerequisites

* [Clarinet](https://github.com/hirosystems/clarinet) >= 1.5.4
* [Node.js](https://nodejs.org/) >= 14.0.0
* [Stacks Wallet](https://www.hiro.so/wallet)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/henryno111/event-insurance
   cd event-insurance
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run tests:
   ```bash
   clarinet test
   ```

### Deployment

1. Generate deployment plan:
   ```bash
   clarinet deployments generate --testnet
   ```

2. Deploy contract:
   ```bash
   clarinet deployments apply --testnet
   ```

## Testing

The contract includes comprehensive tests covering:

* Event registration validation
* Insurance policy creation
* Cancellation mechanisms
* Claims processing
* Error handling
* Date and amount validation

Run the test suite:
```bash
clarinet test tests/event-insurance_test.ts
```

## Security Considerations

1. **Access Control**
   * Organizer verification
   * Oracle authorization
   * Participant validation

2. **Fund Safety**
   * Secure premium collection
   * Protected payouts
   * Time-locked withdrawals

3. **Data Validation**
   * Date verification
   * Amount checks
   * Participant limits

## Error Codes

| Code | Description | 
|------|-------------|
| u1   | Unauthorized |
| u2   | Invalid Amount |
| u3   | Event Exists |
| u4   | Event Not Found |
| u5   | Already Insured |
| u6   | Not Insured |
| u7   | Already Claimed |
| u8   | Event Active |
| u9   | Invalid Date |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.