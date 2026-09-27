# Main server deployment

The `Deploy Main` workflow runs CI, creates a GitHub deployment, and connects
to the `Main` TGServer host with a restricted SSH key. The server runs a
root-owned copy of `tgs_deploy.py` as a forced SSH command under `dpdeploy`.
The key cannot open a shell or forward ports.

The server script reads `/etc/darkparadise/tgs-deploy.json` for a TGServer API
account and instance ID. This file is owned by root and readable only by the
`dpdeploy` group. It is never committed to the repository or stored in GitHub
Actions secrets. The Actions environment `Main` contains only the restricted
SSH private key and connection settings; it permits deployments from
`master220`.

The script updates the TGServer repository to the requested `master220` commit
and compiles it. TGServer stages the compiled code for the next game round.
The workflow does not restart the running game. A deployment succeeds only
after TGServer reports a successful compile for the requested commit.

To check the installed script without changing the game:

```sh
sudo -u dpdeploy /usr/local/libexec/darkparadise-deploy --check
```

Changes to `tgs_deploy.py` in this repository do not automatically replace
the root-owned server copy. Install reviewed changes on the server separately.
