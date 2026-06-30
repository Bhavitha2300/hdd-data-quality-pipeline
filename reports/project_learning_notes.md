## Git and GitHub Workflow Issue

During the project, I encountered a Git workflow issue where SQL file changes were saved in VS Code but were not included in the commit because the files had not been staged with `git add`.

I also noticed that GitHub was not showing contribution activity for some commits. This was caused by commits being authored with an older email address instead of the email connected to my GitHub account. After updating the local Git user email and making a new commit, GitHub correctly counted the contribution.

This helped reinforce the difference between saving a file, staging a file, committing a file, pushing to GitHub, and GitHub contribution attribution.