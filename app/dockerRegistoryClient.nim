import httpClient
import json
import strutils
import os
import osproc

let AuthDockerUrlBase: string = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:"
let DockerRegistryUri: string = "https://registry.hub.docker.com/"


proc addPrefix(imageName: string): string =
    result = "library/" & imageName

proc getImageName(imageName: string): string =
    result = addPrefix(imageName).split(':')[0]

proc getImageReference(imageName: string): string =
    if imageName.contains(":"):
        result = addPrefix(imageName).split(':')[1]
    else:
        result = "latest"

proc getToken(client: HttpClient, imageName: string, operations: seq[string] = @["pull"], token: var string): bool = 
    let authDockerUrl = AuthDockerUrlBase & addPrefix(imageName) & ":" & join(operations, ",")
    let respToken = client.get(authDockerUrl)
    if respToken.status == Http200:
        token = parseJson(respToken.body)["token"].getStr()
        result = true
    else:
        echo "Failed to get token : " & respToken.status
        result = false

proc pullImageManifest(client: HttpClient, imageName: string, manifest: var string): bool =
    let manifestUri: string = DockerRegistryUri & "v2/" & getImageName(imageName) & "/manifests/" & getImageReference(imageName)
    let respManifest = client.get(manifestUri)
    if respManifest.status == Http200:
        manifest = respManifest.body
        result = true
    else:
        echo "Failed to get manifest : " & respManifest.status
        result = false

proc pullImageLayers(client: HttpClient, imageName: string, manifest: string, layerFiles: var seq[string]): bool = 
    layerFiles = @[]
    for items in parseJson(manifest)["fsLayers"]:
        # get a digest from Manifest
        let digest = items["blobSum"].getStr()
        # pull a layer
        let layerUri: string = DockerRegistryUri & "v2/" & getImageName(imageName) & "/blobs/" & digest
        let filename = digest.split(':')[1]
        let respPullLayer = client.get(layerUri)
        if respPullLayer.status == Http200:
            var f = open(filename, fmWrite)
            if not isNil(f):
                f.write(respPullLayer.body)
                f.close()
                layerFiles.add(filename)
                result = true
        else:
            echo "Failed to get image layer : " & respPullLayer.status
            result = false

proc extractImageLayers(layerFiles: seq[string], dstDir: string): void = 
    for items in layerFiles:
        if existsFile(items):
            discard execCmd("tar xf " & items & " -C " & dstDir)
            removeFile(items)

proc pullImage*(imageName: string, dstDir: string): bool = 
    let client = newHttpClient()

    var token: string
    if not getToken(client, imageName, @["pull"], token):
        return false
    client.headers.add("Authorization", "Bearer " & token)

    var manifest: string
    if not pullImageManifest(client, imageName, manifest):
        return false

    var layerFiles: seq[string]
    if not pullImageLayers(client, imageName, manifest, layerFiles):
        return false

    extractImageLayers(layerFiles, dstDir)
    return true