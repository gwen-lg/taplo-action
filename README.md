# Taplo Action
Run check and/or lint on TOML files with [Taplo](https://taplo.tamasfe.dev/)

## Use it in Github Workflow

To use taplo in your Github workflow, you can add a step :
```yaml
      uses: gwen-lg/taplo-action
      with:
          format: true/false
          lint: true/false
```

### Additional inputs:
- `version`: Override the release version of Taplo to use.
- `archive`: Override the name of the archive of Taplo. Used of the name is different for the used version.
