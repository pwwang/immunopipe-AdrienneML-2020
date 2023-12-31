# immunopipe-AdrienneML-2020

Reanalysis of the scRNA-seq and scTCR-seq data from [Luoma, Adrienne M., et al. 2020](https://www.cell.com/cell/fulltext/S0092-8674(20)30688-7) using [immunopipe](https://github.com/pwwang/immunopipe).

> [Luoma, Adrienne M., et al. "Molecular pathways of colon inflammation induced by cancer immunotherapy." Cell 182.3 (2020): 655-671.](https://www.cell.com/cell/fulltext/S0092-8674(20)30688-7)

## Data preparation

The data was downloaded from [GSE144469](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE144469).

There are two sets of data, CD45+ cells and CD3+ cells. The CD3+ cells are sequenced with paired scRNA-seq and scTCR-seq, while the CD45+ cells are sequenced with scRNA-seq only.

See `prepare-data.sh` for details.

## Configuration

> [!NOTE]
> This is not a replication of the original paper, primarily due to the irreproducibility of the clustering results. This is a reanalysis of the data using [`immunopipe`](https://github.com/pwwang/immunopipe), showing the potential of the pipeline similar analyses listed in the paper.

Even though the CD45+ cells are sequenced with scRNA-seq only, we can still use `immunopipe` to perform the analysis. The configuration can be found in `ImmunopipeCD45.config.toml`. The configuration for the CD3+ cells can be found in `ImmunopipeCD3.config.toml`.

## Results/Reports

You can find the results in the `cd45-output` and `cd3-output` directories.

The reports can be found at [https://imp-adrienneml-2020.pwwang.com/cd45-output/REPORTS](https://imp-adrienneml-2020.pwwang.com/cd45-output/REPORTS) and [https://imp-adrienneml-2020.pwwang.com/cd3-output/REPORTS](https://imp-adrienneml-2020.pwwang.com/cd3-output/REPORTS).
