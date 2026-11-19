"""SkullOS Cloud on Modal: a persistent, browser-accessible SkullOS desktop.

Setup (once):
    pip install modal && modal setup
    modal secret create skullos VNC_PASSWORD=choose-a-strong-one \
        SKULL_S3_BUCKET=my-bucket SKULL_S3_REGION=us-east-1 \
        AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... RESTIC_PASSWORD=... SKULL_AUTO_RESTORE=1
    # S3 vars are optional; without them your home lives only on the Modal Volume.

Run:
    modal serve cloud/modal_app.py    # dev URL, stops when you Ctrl-C
    modal deploy cloud/modal_app.py   # stays deployed, scales to zero when idle
Open the printed URL and enter VNC_PASSWORD.
"""
import pathlib
import subprocess

import modal

REPO = pathlib.Path(__file__).resolve().parent.parent

image = modal.Image.from_dockerfile(REPO / "cloud" / "Dockerfile", context_dir=REPO)
home = modal.Volume.from_name("skullos-home", create_if_missing=True)
app = modal.App("skullos-cloud")


@app.function(
    image=image,
    cpu=4,
    memory=8192,
    timeout=24 * 60 * 60,
    scaledown_window=20 * 60,  # keep the desktop alive 20 min after the last tab closes
    max_containers=1,  # one desktop; one writer to the home volume
    volumes={"/home/skull": home},
    secrets=[modal.Secret.from_name("skullos")],
)
@modal.concurrent(max_inputs=100)
@modal.web_server(6080, startup_timeout=180)
def desktop():
    subprocess.Popen(["/usr/local/bin/skull-cloud-start"])
