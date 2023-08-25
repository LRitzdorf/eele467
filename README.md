# Labs and Homework GitHub Repository for EELE467

<p align="center">
<img src=./images/repository_setup_1repo.png width=25%>
</p>


## Suggested Directory Structure

- 📁 **docs**: documentation and lab reports
- 📁 **quartus**: quartus project folder
- 📁 **led-patterns**: everything associated with your led-patterns IP core
- 📁 **devmem2**: devmem2 source code

Organize your project using folders to keep separate things separate.
Do this in a way that makes the most sense to you.
However, keep a relatively flat directory structure, i.e. don't nest a bunch of folders.

Other options:

- 📁 **src**: source files
- 📁 **include**: header files, etc.
- 📁 **test**: test files, e.g. testbenches, unit tests, etc.


## Cloning your GitHub Repository.
You will need to create a local repository on your laptop.  You can do this by using the git clone command:
```sh
$ git clone [url]
```


## Branch and Tag Naming Conventions

**Branch names:** `lab-<#>`, e.g. `lab-7`

**Tag names:** `lab-<#>-submission`, e.g. `lab-7-submission`

Using different branch and tag names help avoid ambiguities for both humans and git alike (git sometimes complains when tag and branch names are the same because it doesn't know which one you're referring to).


## Git Workflow for Labs and Homework

For each lab, you'll create a branch to work on the new lab.
Using a new branch for development, often called a *development branch*, *dev branch*, or *feature branch*, allows you to work on new features without introducing bugs into your production code.
When you're done with the lab, i.e. you're done implementing the new features, you'll merge the *development branch* back into the *main branch*.
Once this merge is complete, you'll *tag* the corresponding commit on the *main branch* to indicate that the lab is done; this is conceptually the same thing as tagging a commit to indicate a new version release (`v0.7.4`, for instance).

1. **Update your local repository** with any changes made to the remote repository:
   ```
   $ git pull
   ```
   **Note:** It is a good habit to get into of issuing a git pull so that any changes made to the remote repository will be reflected in the local repository.
   This also means that you should get into the habit of pushing changes to your remote repository.
1. **Create a new branch:**
   ```sh
   $ git branch lab-7
   ```
1. **Switch to the new branch** (either one of the following commands will work):
   ```sh
   $ git checkout lab-7
   $ git switch lab-7
   ```
1. **Do your development work** and make *atomic commits*[^1] along the way 🙂:
   ```sh
   $ git add
   $ git commit
   $ git push
   repeat
   ```
   **Note:** *when pushing your new branch*, you need to tell git to create that branch on the
remote repository:
   ```sh
   $ git push --set-upstream origin lab-7
   ```
1. When you're done, **merge your work back into main**:
   ```sh
   $ git checkout main
   $ git merge lab-7
   ```
1. **Tag the submission** with the tag name `lab-7-submission` (git will open your default text editor and prompt you for additional information):
   ```sh
   $ git tag -a
   ```
   **Note:** If it takes multiple submissions to get a successfully working lab demonstration, number the tag submissions, i.e. `lab-7-submission1`, `lab-7-submission2`, etc. and end with: `lab-7-submission-final`
1. **Push the commits**:
   ```sh
   $ git push
   ```
1. **Push the tag**, either by specifying it explicitly or by pushing *all* tags:
   ```sh
   $ git push origin lab-7-submission  # to push just the specified tag
   $ git push --tags                   # to push all tags
   ```
1. **Celebrate!** 🎉

[^1]: Working with atomic git commits means your commits are of the smallest possible size.
Each commit does one, and only one simple thing, that can be summed up in a simple sentence. The amount of code change doesn't matter.
Writing atomic commits forces you to you make small, manageable changes as you tackle large tasks.

