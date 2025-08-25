# NCC Finance Flutter APP - Project Backlog

This document outlines all the epics and user stories for the project.

## Deadlines

- Wednesday, 30/07-25 ~ Tuesday, 07/10/25

## Syncs

- 05/08/2025: Alignment, Flutter vs React Native, API vs Firebase. Actions Point: Create a wireframe/prototype of the app.
- 12/08/2025: Technologies: Flutter; Firebase(raised question on the official channel), tasks divided

---

## Epic 1: Foundational UI Scaffolding & Navigation

_Focuses on building the primary, static UI screens for the application based on the new designs, including Dashboard, Expenses, Investments, and their respective creation forms, as well as User account screens and core navigation._

### ✅ [US1] Prototype Core Application Wireframes | [Lary]

- **As a** Product Manager,
- **I want to** have mobile-specific wireframes for all core application screens,
- **so that** the development team has a clear visual blueprint for mobile, adapted from the existing web prototype.

**Acceptance Criteria:**

- **Given** the new application design prototypes,
- **When** a design session is conducted,
- **Then** wireframes for the Login and User Registration (Cadastro) screens must be produced.
- **And** wireframes for the main authenticated screens (Dashboard, Expense Control, Investments) must be produced.
- **And** wireframes for the creation forms (Create Transaction, Create Investment) must be produced.
- **And** these wireframes must be approved before development begins.

### ✅ [US2] Build Static User Login Screen | [Joelton]

- **As a** user,
- **I want to** see a dedicated login screen,
- **so that** I can access my account.

**Acceptance Criteria:**

- **Given** the approved wireframes,
- **When** the Login screen is displayed,
- **Then** it must contain a logo, and input fields for "Email" and "Senha" (Password).
- **And** it must have a primary button for "Acessar" (Access) and a link for "Esqueci a senha?" (Forgot password?).

### ✅ [US3] Build Static User Registration (Cadastro) Screen | [Carlos]

- **As a** new user,
- **I want to** see a dedicated screen to create a new account,
- **so that** I can sign up for the service.

**Acceptance Criteria:**

- **Given** the approved wireframes,
- **When** the Registration screen is displayed,
- **Then** it must display the title "Crie uma nova conta".
- **And** it must contain input fields for "Nome" (Name), "Email", and "Senha" (Password).
- **And** it must have a primary button labeled "Criar conta" (Create account).

### [US4] Build Static 'Update Account' Screen | [Carlos]

- **As a** user,
- **I want to** have a screen to view and update my profile information,
- **so that** I can keep my data accurate.

**Acceptance Criteria:**

- **Given** the approved wireframes,
- **When** the Update Account screen is displayed,
- **Then** it must contain non-editable and editable fields for user information like Name and Email.
- **And** it must contain an option to change the password.
- **And** a "Save Changes" button must be present.

### [US5] Implement Main Tab Bar Navigation

- **As a** logged-in user,
- **I want to** have a main tab bar at the bottom of the screen,
- **so that** I can easily navigate between the primary sections of the app.

**Acceptance Criteria:**

- **Given** a user has successfully logged in,
- **When** the main application interface loads,
- **Then** a tab navigator should be visible at the bottom of the screen.
- **And** the tab bar must contain icons for the main sections, such as Dashboard, Expense Control, and Investments, as seen in the designs.

### [US6] Build Static Dashboard Screen | [Leo]

- **As a** user,
- **I want to** see a dashboard with my balance, quick actions, and recent transactions,
- **so that** I can get a quick overview and access common tasks.

**Acceptance Criteria:**

- **Given** I am on the main Dashboard tab,
- **When** the screen is viewed,
- **Then** it must display a header with a greeting and user name (e.g., "Olá, João da Silva").
- **And** it must show a "Saldo" (Balance) card with a placeholder amount and a visibility toggle icon.
- **And** it must show a horizontal "Quick Actions" component with buttons for "Doação", "Transferência", "Pagamento", etc..
- **And** it must show a "Últimas transações" (Recent transactions) list with several static placeholder items.

### [US7] Build Static 'Expense Control' Screen | [Lary]

- **As a** user,
- **I want to** see a screen dedicated to controlling my expenses,
- **so that** I can understand my spending habits.

**Acceptance Criteria:**

- **Given** I navigate to the 'Expense Control' tab,
- **When** the screen is viewed,
- **Then** it must display a title such as "Controle de gastos".
- **And** it must contain a placeholder for a donut chart meant to show expense categories.
- **And** it must contain a list of static placeholder expense items below the chart, each with a progress bar.

### [US8] Build Static 'Investments' Screen | [Ricardo]

- **As a** user,
- **I want to** see a screen with a summary of my investments,
- **so that** I can track their performance.

**Acceptance Criteria:**

- **Given** I navigate to the 'Investments' tab,
- **When** the screen is viewed,
- **Then** it must show a summary component with placeholders for "Total", "Renda Fixa", and "Renda Variável" investments.
- **And** it must show a static "Estatísticas" component with a placeholder for a donut chart and a legend.

### [US9] Build Static 'Create Transaction' & 'Create Investment' Screens | [Ricardo & Leo]

- **As a** developer,
- **I want to** build the static UI for all creation forms,
- **so that** they are ready to be connected to the API in a future epic.

**Acceptance Criteria:**

- **Given** a user needs to create a new item,
- **When** the 'Create Transaction' screen is opened,
- **Then** a form must be displayed with fields for "Nome da transação" and "Valor".
- **When** the 'Create Investment' screen is opened,
- **Then** a form must be displayed with fields for "Nome do investimento", "Valor", and a "Categoria" dropdown.
- **And** both forms must have "Salvar" (Save) and "Cancelar" (Cancel) buttons.

### [US10] Implement Core Navigation Flows

- **As a** user,
- **I want** the static screens and components to be linked together,
- **so that** I can navigate through the application's main paths.

**Acceptance Criteria:**

- **Given** all static screens from this epic are built,
- **When** I tap a quick action like "Transferência" on the dashboard,
- **Then** I should be navigated to the 'Create Transaction' screen.
- **When** I tap an "Add Investment" button (to be placed on the Investments screen),
- **Then** I should be navigated to the 'Create Investment' screen.
- **When** I tap the profile icon in the main header,
- **Then** I should be navigated to the 'Update Account' screen.

### [US11] Add 'Attach Receipt' UI to Transaction Form

- **As a** user,
- **I want to** see an option to attach a receipt on the transaction form,
- **so that** I know where to add supporting documents for my expenses.

**Acceptance Criteria:**

- **Given** the static 'Create Transaction' screen is built (from US9),
- **When** the screen is displayed,
- **Then** a new UI element, such as a button or an icon link with the label "Anexar comprovante" (Attach receipt), must be present on the form.
- **And** this story only covers the visual creation of the button; tapping it is not required to have any functionality at this stage.

---

## Epic 2: Backend Migration & Logic with Firebase

_Focuses on migrating the application's entire data structure and business logic to the Firebase ecosystem. This includes setting up the project, modeling the data for Firestore, and implementing and testing the core business rules for users, transactions, and investments._

### ✅ [US1] Set Up and Configure Firebase Project | [Joelton]

- **As a** developer,
- **I want to** initialize and configure a new Firebase project with all necessary services enabled,
- **so that** we have a stable foundation for building the backend logic.

**Acceptance Criteria:**

- **Given** a new Firebase project is required,
- **When** the project is created in the Firebase console,
- **Then** Firebase Authentication (with Email/Password provider) must be enabled.
- **And** Cloud Firestore must be initialized in the correct region.
- **And** Firebase Storage must be set up with default security rules.
- **And** the Firebase SDK must be correctly configured in a local development environment for testing.

### ✅ [US2] Model Application Data for Firestore | [Joelton]

- **As a** developer,
- **I want to** define and document the NoSQL data structure for the entire application,
- **so that** all data is stored efficiently and logically in Cloud Firestore.

**Acceptance Criteria:**

- **Given** the application's data requirements from Epic 1,
- **When** the data modeling phase is conducted,
- **Then** a clear structure for a `users` collection must be defined, detailing the fields for a user's profile information.
- **And** a structure for a `transactions` sub-collection within each user document must be defined, detailing the fields like amount, description, category, and date.
- **And** a structure for an `investments` sub-collection must be defined.
- **And** the strategy for managing account balances must be documented (e.g., as a field in the user document or in a separate `balances` collection).

### [US3] Implement Firestore Security Rules | [Joelton]

- **As a** developer,
- **I want to** implement robust security rules for the entire Firestore database,
- **so that** users can only access and modify their own data.

**Acceptance Criteria:**

- **Given** the defined data model,
- **When** the security rules are written and deployed,
- **Then** the rules must ensure a user can only read or write to their own user document and its sub-collections.
- **And** an unauthenticated user must be denied all read/write access.
- **And** the rules must be validated using the Firebase Security Rules Playground to prevent unauthorized access.

### [US4] Implement User Creation and Profile Management Logic

- **As a** developer,
- **I want to** create the backend logic for user registration and profile updates,
- **so that** the core user management functionality is in place.

**Acceptance Criteria:**

- **Given** a user signs up with their credentials,
- **When** the registration logic is executed,
- **Then** a new user must be created in Firebase Authentication.
- **And** a corresponding user profile document must be created in the `users` collection in Firestore, containing their name and email.
- **Given** a user is logged in,
- **When** the update profile logic is called with new information (e.g., a new name),
- **Then** the corresponding user document in Firestore must be updated.

### [US5] Implement Authentication Business Logic

- **As a** developer,
- **I want to** implement the core authentication functions,
- **so that** users can securely log in, log out, and reset their password.

**Acceptance Criteria:**

- **Given** a user provides their email and password,
- **When** the login function is called,
- **Then** it should successfully authenticate the user against Firebase Authentication and return a user session.
- **Given** a user is logged in,
- **When** the logout function is called,
- **Then** the user's session must be securely terminated.
- **Given** a user provides their email,
- **When** the password reset function is called,
- **Then** it should correctly trigger Firebase Authentication's password reset email flow.

### [US6] Implement Business Logic for Account Balances

- **As a** developer,
- **I want to** create functions to reliably read and modify a user's account balance,
- **so that** the balance accurately reflects all transactions.

**Acceptance Criteria:**

- **Given** a new transaction is created,
- **When** the transaction logic is processed,
- **Then** the user's main account balance must be correctly decreased (for expenses) or increased (for income).
- **Given** a transaction is deleted,
- **When** the deletion logic is processed,
- **Then** the user's balance must be reverted accordingly.
- **And** this logic should be encapsulated in reusable functions that can be tested independently.

### [US7] Implement CRUD Logic for Transactions

- **As a** developer,
- **I want to** build the core functions to create, read, update, and delete transaction documents,
- **so that** the app can manage a user's financial activities.

**Acceptance Criteria:**

- **Given** a user's ID and transaction data (name, value, category),
- **When** the "create transaction" function is called,
- **Then** a new document must be added to that user's `transactions` sub-collection in Firestore.
- **And** functions to read a single transaction, read all transactions, update a transaction, and delete a transaction must be implemented and tested.

### [US8] Implement CRUD Logic for Investments

- **As a** developer,
- **I want to** build the core functions to create, read, update, and delete investment documents,
- **so that** the app can manage a user's investment portfolio.

**Acceptance Criteria:**

- **Given** a user's ID and investment data (name, value, category),
- **When** the "create investment" function is called,
- **Then** a new document must be added to that user's `investments` sub-collection in Firestore.
- **And** functions to read a single investment, read all investments, update an investment, and delete an investment must be implemented and tested.

### [US9] Develop Logic for Dashboard and Chart Data

- **As a** developer,
- **I want to** create functions that aggregate raw data for dashboard visualizations,
- **so that** the UI can display meaningful charts and summaries.

**Acceptance Criteria:**

- **Given** a user has multiple transactions with different categories,
- **When** the "expense chart" logic is called,
- **Then** it must query Firestore and return an aggregated summary of spending by category.
- **Given** a user has multiple investments,
- **When** the "investment chart" logic is called,
- **Then** it must query Firestore and return an aggregated summary of investments by category.

### [US10] Implement Unit and Integration Tests for Business Logic

- **As a** developer,
- **I want to** write comprehensive tests for all backend functions,
- **so that** we can ensure the business logic is correct, secure, and reliable before integrating it with the UI.

**Acceptance Criteria:**

- **Given** the business logic for transactions and balances,
- **When** the test suite is run,
- **Then** unit tests must verify that balance calculations are correct.
- **And** integration tests must verify that creating a transaction correctly updates the user's balance in the test database.
- **And** all other critical functions (user profile management, investment CRUD, etc.) must have corresponding unit tests.

---

## Epic 3: UI Integration with Firebase Services

_Focuses on connecting the static UI screens built in Epic 1 with the Firebase backend logic defined in Epic 2. This epic will make the application fully interactive and data-driven._

### [US1] Connect Login & Registration to Firebase Authentication

- **As a** user,
- **I want to** have my inputs on the Login and Registration screens actually create a session or a new account,
- **so that** I can enter the authenticated part of the application.

**Acceptance Criteria:**

- **Given** the static Login and Registration screens from Epic 1,
- **When** a user fills out the registration form and taps "Create Account",
- **Then** the "User Creation and Profile Management Logic" from Epic 2 must be called.
- **When** an existing user fills out the login form and taps "Access",
- **Then** the "Authentication Business Logic" for login from Epic 2 must be called.
- **And** upon successful authentication, the user must be navigated to the main application dashboard.

### [US2] Connect 'Update Account' Screen to Firestore

- **As a** user,
- **I want to** be able to save the changes I make to my profile,
- **so that** my personal information is kept up-to-date.

**Acceptance Criteria:**

- **Given** the static 'Update Account' screen is populated with my data,
- **When** I change my name and tap the "Save Changes" button,
- **Then** the "Update User Profile Information" logic from Epic 2 must be called.
- **And** the UI should display a success message and reflect the updated name in the header.

### [US3] Populate Dashboard with Live Data from Firestore

- **As a** user,
- **I want to** see my real, up-to-date financial information on the dashboard,
- **so that** I can get an accurate overview of my account.

**Acceptance Criteria:**

- **Given** I am on the Dashboard screen,
- **When** the screen loads,
- **Then** the backend logic must be called to fetch the user's name, current balance, and recent transactions.
- **And** the static placeholder components (Header, Balance Card, Recent Transactions) must be populated with the live data returned from Firestore.

### [US4] Populate 'Expense Control' Screen with Live Data

- **As a** user,
- **I want to** see a chart and list of my actual expenses,
- **so that** I can analyze my spending habits.

**Acceptance Criteria:**

- **Given** I am on the 'Expense Control' screen,
- **When** the screen loads,
- **Then** the backend logic to aggregate expense data (from Epic 2) must be called.
- **And** the static donut chart placeholder must be replaced with a live chart displaying the expense data.
- **And** the list below the chart must be populated with my real expense data.

### [US5] Populate 'Investments' Screen with Live Data

- **As a** user,
- **I want to** see a chart and summary of my real investments,
- **so that** I can track my portfolio's performance.

**Acceptance Criteria:**

- **Given** I am on the 'Investments' screen,
- **When** the screen loads,
- **Then** the backend logic to aggregate investment data (from Epic 2) must be called.
- **And** the static summary and chart components must be populated with my live investment data.

### [US6] Connect 'Create Transaction' & 'Create Investment' Forms to Firestore

- **As a** user,
- **I want to** be able to save new transactions and investments,
- **so that** they are recorded in my account.

**Acceptance Criteria:**

- **Given** I am on the 'Create Transaction' screen,
- **When** I fill out the form and tap "Save",
- **Then** the "CRUD Logic for Transactions" from Epic 2 must be called to create a new transaction document in Firestore.
- **Given** I am on the 'Create Investment' screen,
- **When** I fill out the form and tap "Save",
- **Then** the "CRUD Logic for Investments" from Epic 2 must be called to create a new investment document in Firestore.
- **And** upon success, the user should be navigated away from the form, and the relevant data lists should update.

### [US7] Enable Transaction and Investment Deletion from the UI

- **As a** user,
- **I want to** be able to delete transactions or investments I no longer need,
- **so that** I can maintain an accurate financial record.

**Acceptance Criteria:**

- **Given** I am viewing a list of my transactions or investments,
- **When** I perform a delete action on a specific item (e.g., via a button or swipe gesture),
- **And** I confirm the action in a confirmation prompt,
- **Then** the appropriate delete logic from Epic 2 must be called to remove the document from Firestore.
- **And** the item must be removed from the list in the UI.

### [US8] Implement Full Receipt Upload and Linking Flow

- **As a** user,
- **I want to** attach a receipt to a transaction and have it saved permanently,
- **so that** I have a complete digital record of my purchase.

**Acceptance Criteria:**

- **Given** I am on the 'Create Transaction' or 'Edit Transaction' screen,
- **When** I tap the 'Attach Receipt' button (from the UI built in Epic 1),
- **And** I select an image from my device's photo gallery,
- **Then** the app must upload the file to Firebase Storage.
- **And** upon successful upload, the app must call the backend logic to link the returned file URL to the transaction document in Firestore.
- **And** the UI should provide feedback on the upload status (in progress, success, or failure).

---

## Epic 4: UI Polish & Advanced Features

_Focuses on enhancing the now-functional screens. This involves adding the required animated financial graphs to the Dashboard and implementing advanced features required by the program._

### [US1] Implement Dashboard Entry Animations

- **As a** user,
- **I want to** see smooth animations when the dashboard and its components load,
- **so that** the application feels modern, responsive, and polished.

**Acceptance Criteria:**

- **Given** the dashboard screen is about to be displayed with live data,
- **When** the components render,
- **Then** entry animations must be applied as required by the postgraduate program.
- **And** the 'Saldo' (Balance) card should gracefully fade in or slide into view.
- **And** the 'Quick Actions' icons should animate in sequentially (e.g., staggering their appearance).
- **And** the chart components (e.g., on the 'Expense Control' screen) should animate when their data is loaded, such as the donut chart segments drawing themselves.

### [US2] Implement Infinite Scroll for Transaction List

- **As a** user with a long transaction history,
- **I want to** have more transactions load automatically as I scroll to the bottom of the list,
- **so that** I can review my entire history seamlessly without clicking through pages.

**Acceptance Criteria:**

- **Given** the requirement to handle large volumes of data,
- **And** the transaction list is displaying an initial set of results,
- **When** I scroll to the end of the current list,
- **Then** the app must automatically trigger a query to fetch the next "page" of results from Firestore.
- **And** a loading indicator should be briefly visible at the bottom of the list.
- **And** the new transactions must be appended to the bottom of the existing list until all have been loaded.

### [US3] Implement Advanced Validation on Creation Forms

- **As a** user,
- **I want to** be guided with real-time validation when I fill out a transaction or investment form,
- **so that** I can avoid making mistakes and ensure my data is accurate.

**Acceptance Criteria:**

- **Given** the requirement for "Validação Avançada de campos" (Advanced field validation),
- **When** I am on the 'Create Transaction' or 'Create Investment' screen,
- **Then** the "Save" button must be disabled if any required fields (like value or category) are empty.
- **And** if I enter an invalid value (e.g., text in the amount field), an inline error message must appear immediately.
- **And** the form should not allow submission until all validation rules are passed.

### [US4] Implement Animated Screen Transitions

- **As a** user,
- **I want to** see smooth, animated transitions when I navigate between different screens,
- **so that** the app feels fluid, responsive, and high-quality.

**Acceptance Criteria:**

- **Given** the requirement to implement animations for transitions,
- **When** I tap on an icon in the main tab bar to switch screens (e.g., from Dashboard to Investments),
- **Then** the new screen should animate into view using a subtle fade or slide transition.
- **When** I navigate from a list view to a detail view (e.g., tapping a transaction),
- **Then** a standard "push" animation (sliding in from the right) should occur.
- **When** I go back to the previous screen,
- **Then** a "pop" animation (sliding out to the right) should occur.

---

## Epic 5: MVP Security Implementation

_Focuses on implementing the essential security measures required for a viable and secure financial application, prioritizing data protection and fundamental best practices suitable for the project's scope._

### [US1] Secure Data Access with Firestore Rules

- **As a** user,
- **I want to** have my financial data in the cloud protected by strong access rules,
- **so that** I can be confident that only I can read or modify my own information.

**Acceptance Criteria:**

- **Given** our application uses Cloud Firestore to store user-specific data,
- **When** the security rules are written and deployed,
- **Then** the rules must ensure that an authenticated user can only read and write to their own documents (e.g., their user profile and their own sub-collections for transactions and investments).
- **And** an unauthenticated user must be denied all read and write access to user data.
- **And** these rules must be the primary method of data protection, as discussed in the course materials.
- **And** the rules must be validated using the Firebase Security Rules Playground to confirm they prevent cross-user data access.

### [US2] Protect Credentials with Environment Variables

- **As a** developer,
- **I want to** ensure that no sensitive keys or credentials are hardcoded into the application's source code,
- **so that** we follow security best practices and prevent accidental exposure.

**Acceptance Criteria:**

- **Given** the mobile application needs to connect to Firebase,
- **When** the application is built,
- **Then** all Firebase project configuration keys (apiKey, authDomain, etc.) must be loaded from a secure environment file (e.g., .env) and not be directly written in the source code.
- **And** this environment file must be included in the project's .gitignore file to prevent it from being committed to the repository.

### [US3] Implement Basic Client-Side Hardening

- **As a** developer,
- **I want to** implement at least one client-side hardening technique discussed in the course,
- **so that** we demonstrate an understanding of application protection beyond server-side rules.

**Acceptance Criteria:**

- **Given** the course materials on protecting against reverse engineering,
- **When** building the application for production,
- **Then** the team must implement **one** of the following measures:
  - **A)** **Root/Jailbreak Detection:** The app performs a check on startup and shows a non-blocking warning to the user if a compromised environment is detected.
  - **OR**
  - **B)** **Code Obfuscation:** The production build process for the app is configured to enable basic JavaScript obfuscation/minification to make the code harder to read.
- **And** the chosen implementation should be documented in the project's README file.

---

## Epic 6: Project Delivery & Final Submission

_Focuses on fulfilling all the non-code deliverables required for the project submission, including cleaning the repository, creating comprehensive documentation, and producing the final video demonstration and presentation materials._

### [US1] Prepare Final Git Repository for Submission

- **As a** development team,
- **I want to** ensure the project's Git repository is clean, professional, and ready for submission,
- **so that** the evaluator can easily access and review our source code.

**Acceptance Criteria:**

- **Given** that project development is complete,
- **When** preparing for final submission,
- **Then** the source code must be available in a Git repository.
- **And** the `main` or `master` branch must contain the final, stable version of the code.
- **And** the commit history should be clean and follow conventional commit message standards.
- **And** the `.gitignore` file must be properly configured to exclude `node_modules`, environment files (`.env`), and other unnecessary build artifacts.

### [US2] Create Comprehensive README for Project Setup

- **As an** evaluator or new developer,
- **I want to** have a clear and comprehensive README file,
- **so that** I can understand the project's purpose and run it locally without issues.

**Acceptance Criteria:**

- **Given** the Git repository is prepared,
- **When** writing the final documentation,
- **Then** the README must contain a clear project overview, describing its purpose and architecture.
- **And** it must list all necessary dependencies and prerequisites to run the project.
- **And** it must provide step-by-step instructions on how to install dependencies and run the application locally.
- **And** it must include detailed instructions on how to set up the necessary Firebase configuration, including any required environment variables.
- **And** the README must be well-formatted using Markdown for readability.

### [US3] Produce Final Project Demonstration Video

- **As a** development team,
- **I want to** create a concise video demonstrating all the key functionalities of the application,
- **so that** we can effectively showcase our work and meet all submission criteria.

**Acceptance Criteria:**

- **Given** the application is fully functional,
- **When** recording and editing the final demonstration video,
- **Then** the video's total length must not exceed five minutes.
- **And** the video must clearly demonstrate the user login and authentication process.
- **And** it must show the process of adding a new transaction and editing an existing one.
- **And** it must showcase the ability to view and filter the list of transactions.
- **And** the functionality for uploading an attachment (receipt) to a transaction must be demonstrated.
- **And** the video must highlight the integration with Firebase services.
- **And** the video should have clear audio or on-screen text explaining the actions being performed.

### [US4] Create Final Presentation Deck

- **As a** development team,
- **I want to** create a clear and professional presentation deck,
- **so that** we can effectively communicate our project's architecture, challenges, and outcomes during the final presentation.

**Acceptance Criteria:**

- **Given** the project is complete,
- **When** preparing for the final presentation,
- **Then** a set of slides (e.g., PowerPoint, Google Slides) must be created.
- **And** the deck must include slides covering the project's objective, the chosen architecture (and why), and the key technologies used.
- **And** it should highlight the main features implemented.
- **And** it should discuss at least one major challenge faced and how the team overcame it.
- **And** it should conclude with key learnings and potential future improvements.
