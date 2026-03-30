# Optional: publish as `balloon-tap-2` on GitHub

This tree is **Balloon Tap 2.0** in place (`version: 2.0.0+200`). To host it as a **separate** repository named `balloon-tap-2` without losing history:

```bash
# From this repo (clean working tree, on main)
git remote rename origin upstream   # if you want to keep a link to the original
gh repo create balloon-tap-2 --public --source=. --remote=origin --push
# or: create an empty repo on GitHub, then:
# git remote add origin https://github.com/<you>/balloon-tap-2.git
# git push -u origin main
```

Update `README.md` title/URLs if the product name on stores will be “Balloon Tap 2.0”.
