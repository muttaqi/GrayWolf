if [ -d "woops" ]
then
    cd woops
    git fetch origin main
    git reset --hard origin/main
    cd ..
else
    git clone https://github.com/muttaqi/woops.git/
fi