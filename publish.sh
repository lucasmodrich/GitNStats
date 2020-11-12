#!/usr/bin/env bash
set -e

framework=net5.0
bin=src/gitnstats/bin/Release

echo "Cleaning ${bin}"
rm -rf ${bin}/**

# build the list of runtimes by parsing the *.csproj for runtime identifiers
IFS=';' read -ra runtimes <<< "$(grep '<RuntimeIdentifiers>' src/gitnstats/gitnstats.csproj | sed -e 's,.*<RuntimeIdentifiers>\([^<]*\)</RuntimeIdentifiers>.*,\1,g')"

for runtime in ${runtimes[@]}; do
    echo "Restoring ${runtime}"
    dotnet restore -r ${runtime}
    
    echo "Packaging ${runtime}"
    dotnet publish -c release -r ${runtime}
    
    build=${bin}/${framework}/${runtime}
    publish=${build}/publish
    
    if [[ ${runtime} != win* ]]; then
        exe=${publish}/gitnstats
        echo "chmod +x ${exe}"
        chmod +x ${exe}
    fi
    
    # subshell so we can specify the archive's root directory
    (
        cd ${publish}
        archive=../../${runtime}.zip
        echo "Compressing to ${archive}"
        7z a ${archive} ./
    )
done
exit 0