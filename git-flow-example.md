# Example

### 1. Create feature branches from master
`git checkout master`
`git chekout -b feature/ef-1`
`echo 'This is a test' > 1.txt`
`git push origin feature/ef-1`

`git checkout master`
`git chekout -b feature/ef-2`
`echo 'This is a test' > 2.txt`
`git push origin feature/ef-2`

`git checkout master`
`git chekout -b feature/ef-3`
`echo 'This is a test' > 3.txt`
`git push origin feature/ef-3`

### 2. Create PR from feature branches to develop


### 3. Create release branch from master
`git checkout master`
`git chekout -b release/0.1`
`git merge feature/ef-1 feature/ef-2 --no-ff`
`git push origin release/0.1`

### 4. Merge release branch to master
`git checkout master`
`git merge release/0.1 --no-ff`
`git push origin master`

### 5. Remove feature branches
`git branch -d feature/ef-1`
`git branch -d feature/ef-2`

### 6. Rebase feature branches to master
`git chekout -b feature/ef-3`
`git rebase master`
`git push origin feature/ef-3`

### 7. Reset develop to fresh master and merge feature branches to develop
`git checkout develop`
`git reset --hard origin/master`
`git merge feature/ef-3 --no-ff`
`git push origin develop --force`
