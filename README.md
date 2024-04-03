# helm-label
This helm plugin allows you to operate with the labels associated with releases, setting using the flag -l or --labels during the helm install o helm upgrade command

## Instal

To install this plugin run the command 

```sh
helm plugin install https://github.com/nfantoni/helm-label
````

## Usage

```sh
helm label [command] <release-name>
````

### Command

- **list**: Retrieves the list of all the labels associated with a release in json format  
  example:
  ```sh
  helm label list my-release
  ```
  output:
  ```sh
  {"modifiedAt":"1712155699","name":"my-release","owner":"helm","status":"deployed","version":"1"}
  ```
