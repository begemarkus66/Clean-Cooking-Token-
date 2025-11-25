# 🔥 Clean Cooking Token (CCT)

![Stacks](https://img.shields.io/badge/Built%20on-Stacks-blueviolet) ![Clarity](https://img.shields.io/badge/Smart%20Contract-Clarity-orange) ![Status](https://img.shields.io/badge/Status-Active-green)

A blockchain-based incentive system that rewards users for adopting and using clean cooking technologies. Built on the Stacks blockchain using Clarity smart contracts.

## 🌟 Overview

The Clean Cooking Token (CCT) is a fungible token designed to promote clean cooking practices by:
- 🏠 **Registering clean cooking stoves** with efficiency ratings
- ✅ **Verifying stoves** through authorized validators  
- 📊 **Tracking cooking sessions** and usage hours
- 💰 **Rewarding daily participation** with efficiency bonuses
- 🔒 **Ensuring transparency** through blockchain technology

## 🚀 Features

### Core Functionality
- **SIP-010 Compliant**: Full fungible token standard implementation
- **Stove Registration**: Users can register up to 10 clean cooking stoves
- **Verification System**: Authorized verifiers validate stove installations
- **Usage Tracking**: Log cooking sessions with hour-based tracking
- **Daily Rewards**: Claim tokens daily based on stove efficiency
- **Efficiency Bonuses**: Higher efficiency stoves earn 2x rewards

### Token Details
- **Name**: Clean Cooking Token
- **Symbol**: CCT
- **Decimals**: 6
- **Total Supply**: 1,000,000 CCT
- **Daily Reward**: 0.1 CCT base amount
- **Registration Reward**: 0.5 CCT per stove

## 📋 Contract Functions

### Read-Only Functions

#### Token Information
- `get-name()` - Returns token name
- `get-symbol()` - Returns token symbol  
- `get-decimals()` - Returns decimal places
- `get-balance(who)` - Get user's token balance
- `get-total-supply()` - Current circulating supply
- `get-token-uri()` - Token metadata URI

#### Stove & User Data
- `get-stove-info(stove-id)` - Retrieve stove details
- `get-user-stoves(user)` - List user's registered stoves
- `get-user-stats(user)` - User statistics and metrics
- `get-daily-claim-info(user, day)` - Daily claim history
- `can-claim-daily-reward(user)` - Check claim eligibility
- `is-authorized-verifier(verifier)` - Check verifier status

#### Calculations
- `calculate-current-day()` - Current day based on block height
- `calculate-efficiency-reward(base-amount, efficiency)` - Reward calculation

### Public Functions

#### Token Operations
- `transfer(amount, from, to, memo)` - Transfer tokens
- `mint(amount, to)` - Mint new tokens (owner only)
- `set-token-uri(new-uri)` - Update token metadata (owner only)

#### Stove Management
- `register-stove(stove-type, efficiency-rating)` - Register a new stove
- `verify-stove(stove-id)` - Verify stove installation (verifiers only)
- `log-cooking-session(stove-id, hours)` - Record cooking session

#### Rewards
- `claim-daily-reward()` - Claim daily rewards based on efficiency

#### Administration  
- `add-authorized-verifier(verifier)` - Add verifier (owner only)
- `remove-authorized-verifier(verifier)` - Remove verifier (owner only)
- `emergency-pause()` - Emergency control (owner only)

## 🛠️ Usage Instructions

### Getting Started

1. **Deploy the Contract**
   ```bash
   clarinet deploy --testnet
   ```

2. **Register Your First Stove**
   ```clarity
   (contract-call? .clean-cooking-token register-stove "improved-cookstove" u8)
   ```

3. **Get Your Stove Verified**
   - Contact an authorized verifier
   - Provide stove-id and installation proof
   - Verifier calls: `(contract-call? .clean-cooking-token verify-stove u1)`

4. **Log Cooking Sessions**
   ```clarity
   (contract-call? .clean-cooking-token log-cooking-session u1 u3)
   ```

5. **Claim Daily Rewards**
   ```clarity
   (contract-call? .clean-cooking-token claim-daily-reward)
   ```

### Efficiency Ratings
- **1-7**: Standard reward rate
- **8-10**: 2x bonus multiplier for high-efficiency stoves
- **Maximum**: 10 (highest efficiency rating)

### Reward System
- **Base Daily Reward**: 0.1 CCT
- **Efficiency Bonus**: 2x multiplier for ratings ≥8
- **Registration Bonus**: 0.5 CCT per verified stove
- **Claim Frequency**: Once per day (144 blocks)

## 🔧 Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Node.js for testing framework
- Stacks wallet for testnet deployment

### Testing
```bash
clarinet check  # Validate contract syntax
clarinet test   # Run test suites
```

### Local Development
```bash
clarinet console  # Interactive testing environment
```

## 🔐 Security Features

- **Access Control**: Owner-only functions for critical operations
- **Verification System**: Authorized verifiers prevent fraud
- **Rate Limiting**: Daily claim limits prevent abuse
- **Input Validation**: Comprehensive parameter checking
- **Emergency Controls**: Pause functionality for critical issues

## 📈 Economic Model

### Supply Distribution
- **Initial Supply**: 1M CCT minted to contract owner
- **Daily Rewards**: Distributed based on usage and efficiency
- **Registration Incentives**: Immediate rewards for stove registration
- **Deflationary**: No additional minting beyond rewards

### Incentive Alignment
- **Usage-Based**: Rewards require active cooking sessions
- **Quality-Focused**: Higher efficiency stoves earn more
- **Verification-Gated**: Only verified stoves can earn rewards
- **Community-Driven**: Decentralized verifier network

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure `clarinet check` passes
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙋‍♂️ Support

For questions or support:
- 📧 Create an issue in this repository
- 💬 Join our Discord community
- 📖 Check the documentation wiki

---

*Built with ❤️ for a cleaner, more sustainable future through blockchain technology*

# Clean Cooking Token 

