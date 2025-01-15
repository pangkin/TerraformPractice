cat << EOF > ~/.ssh/config
Host ${hostname}
  HostName ${hostname}
  IdentityFile ${identityfile}
  User ${username}
EOF
