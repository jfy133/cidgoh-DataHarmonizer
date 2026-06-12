# MIxS MInAS instructions

## Repository Setup

- Clone the repository
- Install all dependencies set up as described below in the original [DataHarmonizer](https://github.com/cidgoh/DataHarmonizer?tab=readme-ov-file#prerequisites) with `yarn`
  - Configure `corepack` so `yarn` works properly
  - Run `yarn` to install dependencies
- Make sure you've installed [LinkML](https://linkml.io/)
- Make sure you've installed [linkml-toolkit](https://github.com/genomewalker/linkml-toolkit)

## Notes on upstream syncing

Syncing with the upstream DataHarmonizer repository can be a bit tricky as it seems it's a sort of 'production' repository.

Some notes when attempting such a synchronisation:

- Always check updated instructions on the core DataHarmonizer repository
- Start on a branch
- It's generally a good idea to run from scratch
  - `git reset --hard e70027d` to the original forking point of this repo
  - `git merge upstream/master` to get the latest changes
  - Then re-run the instructions below to set up the MInAS DataHarmonizer instance, starting from scratch
- Don't forget to run `yarn` in the root to make sure we get all the latest dependencies etc
- Don't forget to port over the changes to the `web/index.html` HTML file with our header customisation
- You will likely have a merge conflict when opening the PR - follow GitHub instructions then use this for easiest resolution

  ```bash
  git checkout --ours .
  git add .
  ```

- Rebuild `yarn build:dev` for safety

## Notes on HTML editing

- You want to edit the `web/index.html` file to customise the HTML interface around the DataHarmonizer table
- Make sure to run `yarn format` before pushing

### Schema preparation

The instructions for adding a **single extension** to this repo's DataHarmonizer instance:

- Change into `cd web/templates`
- Delete most of the contents of `/web/templates/` (leave one example until the new templates are added, e.g. keep `mpox`, and also `new/` for reference)
- Delete `menu.json`
- Make a directory `mixs-minas/` and change into it
- Add to directory a file `export.js` just containing `export default {};`

  ```bash
  echo "export default {};" > export.js
  ```

  - Write a txt file called (`dh_class_text.txt`) which includes the text for an additional classed called [`dh_interface` class](https://github.com/cidgoh/DataHarmonizer?tab=readme-ov-file#making-templates)

    ```yaml
    dh_interface:
      name: dh_interface
      description: A DataHarmonizer interface
      from_schema: https://github.com/MIxS-MInAS/minas
    MInAS-checklists:
      name: MInAS-checklists
      description:
        The Minimum Information about any Ancient Sequence (MInAS) project aims
        to develop standardised metadata reporting schemes of ancient DNA samples and
        sequencing data via community-based consensus and training.
        This checklist contains relevant aDNA MIxS combinations plus the ancient and
        radiocarbon extension
      is_a: dh_interface
    ```

    > [!WARNING]
    >
    > - Ensure you keep the leading tab indentation!
    > - Ensure you have a final empty new line at the end of the file!

### Creating the DataHarmonizer compatible schema

- Make sure you are in `web/templates/mixs-minas/`

- Download the mixs-minas latest release's schema

  ```bash
  MIXS_MINAS_VERSION=0.7.0
  curl -o mixs-minas.yaml https://raw.githubusercontent.com/MIxS-MInAS/MInAS/refs/tags/v$MIXS_MINAS_VERSION/src/mixs/schema/mixs-minas.yaml
  ```

  - Subset the mega schema to just those combinations relevant to MInAS (i.e., the ones in `minas-combinations.yml`)

  ```bash
  ## Update based on combinations from `minas-combinations.yml`
  lmtk subset --schema mixs-minas.yaml --output minas.yml --classes MixsCompliantData,Ancient,MimsHostAssociatedAncient,MimsHumanAssociatedAncient,MimsHumanOralAncient,MimsHumanGutAncient,MimsHumanSkinAncient,MimsSedimentAncient,MimsSoilAncient,MimsPlantAncient
  ```

  - Inject the `dh_class` into the `schema.yaml` file with e.g.

  ```bash
  sed -i '/^classes:/r dh_class_text.txt' minas.yml
  ```

  - Generate the DataHarmonizer compatible JSON with:

  ```bash
  python ../../../script/linkml.py -i minas.yml
  ```

  WARNING: despite the DataHarmonizer docs saying the `menu.json` will be updated - this does not happen.

  - (Manually) Add the MInAS combinations entries to the **TOP** of `menu.json`, and set these to true

    ```bash
    ## Only activate schemas we are interested in displaying
    ## This works by finding the first string, then in the replacement pattern skip two lines (N;), then perform the actual replacement

    sed -i 's/true/false/g' ../menu.json
    sed -i "/Ancient\"\,/{N;N;s/false/true/g}" ../menu.json
    ```

- Replace the version in the interface header

  ```bash
  cd ../../../
  sed -i 's/MInAS version: 0.5.0/MInAS version: 0.6.0/g' minas-dataharmonizer-header.txt
  sed -i 's/MInAS version: 0.5.0/MInAS version: 0.6.0/g' web/index.html
  ```

  > [!WARNING]
  > Don't forget to update the strings in the command above

### Testing the DataHarmonizer instance

- Test in a local web server
  - Open a local webserver with `yarn dev`
  - Check you can see the new template under 'Template:` in the top bar

### Generating the static DataHarmonizer files

- Generate the static files (within the local clone) in `/web/dist`

  ```bash
  yarn build:web
  ```

- Remove the old docs directory at the root of the repository

  ```bash
  rm -r docs/
  ```

- Copy the new files into `docs/` to allow rendering on GitHub pages

  ```bash
  cp -r web/dist/* docs/
  ```

- Commit and push, checking the GitHub Actions workflow runs successfully

  ```bash
  ## Assuming you want to push everything!
  git commit -am "Update MInAS DataHarmonizer to MInAS v0.6.0"
  git push origin master
  ```
