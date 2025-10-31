# AWS CLI Profiles & Credentials Cheatsheet

## 🔹 Profile Management
- **Create/Edit default profile (interactive)**
  ```bash
  aws configure
  ```

- **Create/Edit named profile (interactive)**
  ```bash
  aws configure --profile profile_admin
  ```

- **Create/Edit named profile (non-interactive)**
  ```bash
  aws configure set aws_access_key_id <ACCESS_KEY_ID> --profile profile_admin
  aws configure set aws_secret_access_key <SECRET_ACCESS_KEY> --profile profile_admin
  aws configure set region ap-south-1 --profile profile_admin
  aws configure set output json --profile profile_admin
  ```
  ⚠️ Keys shell history me save ho sakti hain (use carefully).

- **List all profiles**
  ```bash
  aws configure list-profiles
  ```

- **Check active profile config**
  ```bash
  aws configure list
  AWS_PROFILE=profile_admin aws configure list
  ```

- **Delete profile (manual edit)**
  ```bash
  vi ~/.aws/credentials
  vi ~/.aws/config
  ```

---

## 🔹 Identity & Credentials Validation
- **Check current account identity**
  ```bash
  aws sts get-caller-identity
  aws sts get-caller-identity --profile profile_admin
  ```

- **Get temporary credentials with MFA**
  ```bash
  aws sts get-session-token     --serial-number arn:aws:iam::<account-id>:mfa/<user>     --token-code <MFA_CODE>     --profile profile_admin
  ```

---

## 🔹 Temporary Profile Switching
- **One command ke liye profile use karna**
  ```bash
  AWS_PROFILE=profile_admin aws s3 ls
  ```

- **Switch profile for entire session**
  ```bash
  export AWS_PROFILE=profile_admin
  ```

- **Back to default**
  ```bash
  unset AWS_PROFILE
  ```

- **Permanent default profile (zsh)**
  ```bash
  echo 'export AWS_PROFILE=profile_admin' >> ~/.zshrc
  source ~/.zshrc
  ```

- **Permanent default profile (bash)**
  ```bash
  echo 'export AWS_PROFILE=profile_admin' >> ~/.bashrc
  source ~/.bashrc
  ```

---

## 🔹 Useful Helpers
- **Check AWS config & credentials file**
  ```bash
  cat ~/.aws/config
  cat ~/.aws/credentials
  ```

- **Get active region**
  ```bash
  aws configure get region --profile profile_admin
  ```

- **Get output format**
  ```bash
  aws configure get output --profile profile_admin
  ```
