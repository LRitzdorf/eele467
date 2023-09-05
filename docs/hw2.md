# Lab 2: Getting Started with Git

## Class Workflow Summary

This is simply a reworded summary of the workflow described in the [primary README](/README.md), written to demonstrate understanding of the process and to serve as a practice exercise for said process.

0. Pull any changes from the remote repo.
   This should never be necessary for the purposes of this class, since we're the only users of our respective repos, but is a good habit to get into at the beginning of each work session.
   ```sh
   $ git pull
   ```
1. Create (if necessary) and check out a new feature branch, on which to complete the current assignment.
   ```sh
   $ git checkout -b lab-2  # if the branch does not exist yet
   $ git checkout lab-2     # if the branch already exists
   ```
1. Perform development work to complete the assignment.
   At appropriate points, pause to commit your work.
   These should be "atomic commits"; that is, each commit should accomplish one isolated task (to the degree that is possible).
   ```sh
   $ git add <files>
   $ git commit
   ```
   Also, if you realize that you've made too many changes since your last commit, it is possible to stage selected changes from your working tree, instead of an entire file at a time.
   This is accomplished using *patch mode*:
   ```sh
   $ git add -p <files>
   ```
   In this mode, Git will prompt you interactively to stage (or not) each "hunk", or block of changes, in the files specified.
1. Push your recent work.
   While a push can be performed at any time, there's no requirement to push after every commit.
   Especially for this class, where we don't need to worry about anyone else pushing before us, it may be more efficient to simply push once, at the end of each work session.
   ```sh
   $ git push
   ```
   Also, if the current branch does not yet exist, an extra flag is required when pushing:
   ```sh
   $ git push -u origin lab-2
   ```
   If this is the case, but you attempt to push normally, Git will display an error message which includes the above command for you to copy and paste directly into your shell.
1. Once the assignment is complete, merge its feature branch back into `main`.
   The setup instructions for this course include setting a configuration option that disables fast-forward merging, so even if a fast-forward merge is possible, Git will perform a standard two-parent merge.
   This should make the resulting history slightly clearer for students to visualize, since the branch structure remains visible as a branch and a merge commit.
   ```sh
   $ git checkout main
   $ git merge lab-2
   $ git push           # push the newly-created merge commit
   ```
1. Tag the resulting merge commit as your submission for the assignment.
   We'll do this using annotated tags:
   ```sh
   $ git tag -a lab-2-submission
   ```
   Git will open an editor for you to write a tag message; this course has no specific requirement for tag message content.
1. Push the new tag so it is visible to graders.
   Use *either* of the following commands:
   ```sh
   $ git push origin lab-2-submission  # push just the specified tag
   $ git push --tags                   # push all tags from your local repo
   ```

