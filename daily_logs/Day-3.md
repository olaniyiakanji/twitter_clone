# Day 3

Day 3 of the Twitter Clone project marked significant progress in various critical areas. However, it was not without its share of challenges and hurdles.

# Breakdown
## Architectural Setup
1. **Project Structure**: Refined and documented the project's architectural and folder patterns, ensuring a systematic and organized codebase for the entire development process.

## User Interface (UI) Development
2. **Login and Signup UI (Continued)**: Continued refining the login and signup UI components, focusing on visual enhancements and user experience.

## Authentication
3. **User Login**: Successfully implemented user login using Appwrite Auth, providing users with a secure and hassle-free login process.

## Navigation
4. **Navigation Integration**: Added proper navigation within the app, ensuring seamless transitions between different screens and enhancing user flow.

## State Management
5. **State Persistence**: Implemented state management to persist authentication state, so users don't need to log in repeatedly. I also needed to maintain and store states globally.

# Challenges
- **Architectural Decisions**: Making decisions regarding the project's architecture and folder structure required careful consideration to ensure scalability and maintainability.
- **UI Refinements**: Continuously refining the UI components demanded attention to detail and design principles to create an engaging user experience. Some early decisions concerned which view contexts to pop and when and which to push.
- **Authentication Setup**: While implementing user login, configuring and fine-tuning Appwrite Auth presented its own set of challenges.
- **State Management**: Developing state management solutions and ensuring they work seamlessly within the app's context required thorough testing and debugging. Every context requiring update due to state change has to be respawned (if not visual) or re-rendered (if otherwise). I used the flutter package `riverpod` for universal state management.


