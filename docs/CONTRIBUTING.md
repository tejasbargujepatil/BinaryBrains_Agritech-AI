# Contributing to KrishiMitra 🤝

Thank you for your interest in contributing to KrishiMitra! We welcome contributions from developers, agronomists, and designers to help us build the future of smart farming.

---

## 🛠 Getting Started

1.  **Fork the Repository**: Click the "Fork" button on the top right of this page.
2.  **Clone your Fork**:
    ```bash
    git clone https://github.com/your-username/KrishiMitra.git
    cd KrishiMitra
    ```
3.  **Set Up Environment**:
    - Follow the setup guide in `docs/FRONTEND_GUIDE.md` for the mobile app.
    - Follow the setup guide in `docs/BACKEND_GUIDE.md` for the API.

---

## 💻 Development Workflow

1.  **Create a Branch**:
    Always create a new branch for your changes.
    ```bash
    git checkout -b feature/amazing-new-feature
    # or
    git checkout -b fix/critical-bug-fix
    ```

2.  **Coding Standards**:
    - **Flutter**: Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide. Run `flutter analyze` before committing.
    - **Python**: Follow [PEP 8](https://peps.python.org/pep-0008/). Run `pytest` for backend changes.

3.  **Commit Messages**:
    Use clear and descriptive commit messages.
    ```
    feat: Add new soil health chart
    fix: Resolve crash on login screen
    docs: Update API documentation
    ```

---

## 🧪 Testing

-   **Frontend**: Ensure the app builds and runs without errors.
    ```bash
    flutter test
    ```
-   **Backend**: Run the integration tests script.
    ```bash
    ./KrishiMitra-backend/test_all_endpoints.sh
    ```

---

## 📝 Pull Requests

1.  Push your changes to your fork.
2.  Open a Pull Request (PR) to the `main` branch of the original repository.
3.  Fill out the PR template describing your changes.
4.  Wait for review! We aim to review PRs within 48 hours.

---

## 🐛 Reporting Bugs

If you find a bug, please open an issue on GitHub with:
-   Steps to reproduce.
-   Expected vs. actual behavior.
-   Screenshots or logs.

---
*Happy Coding! 🌾*
