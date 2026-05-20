import sys
import pandas as pd
from datar import f
from datar.base import unique, min_, max_
from datar.tibble import tibble, column_to_rownames
from datar.dplyr import filter_, bind_rows, mutate
from pathlib import Path


def match_one_cluster(markers, cluster, ip_markers_dir):
    # print(markers)
    cluster_markers = markers >> filter_(f.Cluster == cluster, f.Method == "FindMarkers")
    # print(cluster_markers)
    matches = {}
    for markerfile in ip_markers_dir.glob("*/markers.txt"):
        ip_cluster = markerfile.parent.name
        ip_markers = pd.read_csv(markerfile, sep="\t").gene
        matched_markers_idx = cluster_markers.Marker.isin(ip_markers)
        matches[ip_cluster] = sum(cluster_markers.Stats[matched_markers_idx]) / sum(
            cluster_markers.Stats
        )

    df = tibble(**matches)
    df["Cluster"] = cluster
    return df


if __name__ == "__main__":
    if len(sys.argv) > 1:
        kind = sys.argv[1].upper()
    else:
        print("Usage: python match_markers.py <cd3|cd45>")
        sys.exit(1)

    markers = Path(__file__).parent / f"markers_{kind}.txt"
    markers = pd.read_csv(markers, sep="\t") >> mutate(
        Stats=(f.Stats - min_(f.Stats)) / (max_(f.Stats) - min_(f.Stats))
    )
    clusters = unique(markers.Cluster)

    ip_markers_dir = list(
        Path(__file__).parent.parent.glob(
            f"{kind.lower()}-output/"
            "ClusterMarkers/"
            "*.markers/"
            "Cluster",
        )
    )
    if len(ip_markers_dir) == 0 or not ip_markers_dir[0].exists():
        print(f"Directory {ip_markers_dir} does not exist")
        sys.exit(1)

    df = None
    for cluster in clusters:
        df = bind_rows(df, match_one_cluster(markers, cluster, ip_markers_dir[0]))
        # break

    df = df >> column_to_rownames(f.Cluster)
    print(df)
