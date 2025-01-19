## CONTRIBUTING

Please make a pull request to [Dev Branch](https://github.com/Ratimon/superfuse-forge/tree/dev)

### Developer's Quick Guide



### Publishing

#### For First Time

```bash
npm publish
```

#### For Second Time

>[!WARNING]
> For Repo Owner only!!

```bash
git add .
git commit -am "v0.0.5"
git push -u origin main
git tag v0.0.5 main
git push origin tag v0.0.5
```
>[!WARNING]
> DONT forget to add secret env `NPM_AUTH_TOKEN` at [repo](https://github.com/Ratimon/superfuse-wizard/settings/secrets/actions)