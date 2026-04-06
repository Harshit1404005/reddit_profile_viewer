# Reddit API Access Guide

This document contains the official instructions and recommended technical answers for requesting **Data API Access** for the RedditScope application. Since Reddit has moved to a manual review process, use these details to increase your chances of approval.

## 1. Access Request Form
Submit your request here: 
**[Reddit API Access Request Form](https://support.reddithelp.com/hc/en-us/requests/new?ticket_form_id=14868593862164)**

---

## 2. Recommended Form Responses

### Core Classification
*   **Assistance Type**: `API Access Request`
*   **Role**: `I'm a developer`
*   **Inquiry Type**: `I’m a developer and want to build a Reddit App that does not work in the Devvit ecosystem.`

### Application Identity
*   **App Name**: `RedditScope`
*   **Contact Email**: [Your Email]
*   **Reddit Username**: `Harshit1404005`

### Technical Context (Use these answers)
*   **What is the benefit/purpose of your app?**
    > "RedditScope is a Flutter-based analytical tool designed for behavioral mapping and profile quantification. It allows users to visualize their own or public digital footprints, karma distribution, and engagement history for personal insights and educational data science purposes."

*   **Detailed Description of usage**:
    > "The app fetches public profile data (Karma, account age) and the last 10-25 public posts/comments to generate a 'Sentiment Map' and 'Risk Assessment Profile'. All data processing is done locally on the client device, and the app adheres strictly to read-only operations."

*   **Why is Devvit not suitable?**
    > "We are building a standalone, cross-platform mobile application using Flutter to provide a side-by-side behavioral dashboard. Devvit is restricted to embedded experiences within the Reddit UI, which does not support our multi-screen visualization and custom theme requirements."

*   **Source Code / Portfolio**:
    > `https://github.com/Harshit1404005/reddit_profile_viewer`

---

## 3. How to Update the App Once Approved
Once you receive your `CLIENT_ID` and `CLIENT_SECRET` in your email or via the `prefs/apps` page:

1.  Open the **`.env`** file in the project root.
2.  Paste your credentials into the corresponding fields.
3.  Restart the application.
4.  The system will automatically detect the keys and switch from **Public Mode** to **Secure Mode (OAuth)**.

> [!NOTE]
> Until you are approved, the app will continue to function using the **Public Engine** (via `.json` endpoints), allowing you to continue development and testing.
