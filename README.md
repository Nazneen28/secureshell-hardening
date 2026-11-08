# SecureShell Hardening Auditor

A Bash-based SSH security auditing tool that evaluates SSH server configuration against selected security-hardening practices. It identifies insecure settings, calculates a security score, generates a JSON report, and supports optional automatic remediation.

This project was developed as part of my Cloud Engineering learning journey.

## Features

- Audits SSH configuration using 7 security checks
- Detects insecure SSH settings
- Calculates a security score based on passed checks
- Generates JSON security reports
- Creates timestamped audit logs
- Supports optional automatic remediation with `--fix`
- Creates a backup before modifying configuration files
- Includes secure and intentionally insecure sample configurations
- Uses ShellCheck for Bash code quality validation

## Security Checks

| Check                           | Points |
| ------------------------------- | -----: |
| PermitRootLogin disabled        |     15 |
| PasswordAuthentication disabled |     15 |
| PermitEmptyPasswords disabled   |     10 |
| X11Forwarding disabled          |     10 |
| MaxAuthTries ≤ 4                |     10 |
| ClientAliveInterval configured  |     10 |
| AllowTcpForwarding disabled     |     10 |
| **Total**                       | **80** |

## Tech Stack

- **Language:** Bash
- **Platform:** macOS development environment; Linux SSH configuration auditing intended
- **Testing:** Bash syntax validation, ShellCheck, sample configuration testing
- **Output:** JSON security report
- **Version Control:** Git and GitHub

## Project Structure

```text
secureshell-hardening/
├── harden.sh
├── sample_sshd_config
├── sample_sshd_config_secure
├── README.md
├── .gitignore
└── .github/
    └── workflows/
        └── security-audit.yml
```

Generated files such as reports, logs, and backups may be excluded through `.gitignore`.

## Usage

Run the auditor against a sample SSH configuration:

```bash
bash harden.sh sample_sshd_config
```

Run against the secure sample:

```bash
bash harden.sh sample_sshd_config_secure
```

Enable automatic remediation on a sample configuration:

```bash
bash harden.sh --fix sample_sshd_config
```

The remediation process creates a backup before modifying the configuration.

## Validation Results

| Test scenario                 | Result                                 |
| ----------------------------- | -------------------------------------- |
| Secure sample configuration   | 80/80 — 100%                           |
| Insecure sample configuration | 0/80 — 0%                              |
| Automatic remediation         | Successfully corrected sample settings |
| Backup creation               | Verified                               |
| Bash syntax check             | Passed                                 |
| ShellCheck                    | Passed                                 |

## Important Limitations

- This is a learning project, not a complete CIS compliance scanner.
- The checks cover selected SSH configuration settings only.
- The score represents the checks implemented in this project, not overall server security.
- The remediation feature has been tested using sample configuration files.
- Do not run automatic remediation against production servers without appropriate testing, review, and backups.
- Linux deployment and AWS EC2 validation are future development goals.

## Learning Objectives

- Bash scripting and automation
- Linux SSH security fundamentals
- Configuration auditing
- Security scoring and reporting
- JSON generation
- Error handling and debugging
- Cloud infrastructure security concepts

---

**Author:** Nazneen
**Project:** Cloud Engineering Learning Journey
