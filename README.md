# FormData
FormData support where window.FormData is undefined

## About FormData

This is project was inspired by [html5-formdata](https://github.com/francois2metz/html5-formdata/blob/master/README.md) and it implements `FormData` with `append` and `toString` methods.

But unlike **html5-formdata**, it supports `Blob`  and use `FileReader` and `ArrayBuffer` to convert `Blob` to string.

## NPM Use
```
npm install formdata-emulate
```

## How to use it ?

import *formdata.js*:

```html
  <script type="text/javascript" src="formdata.js"></script>
```
use XMLHttpRequest.

```javascript
  var formData = new FormData();
  formData.append("username", "sam");
  // HTML file input, chosen by user
  formData.append("userfile", document.querySelector("#file").files[0]);
  // JavaScript file-like object
  var content = '<a id="a"><b id="b">hey!</b></a>'; // the body of the new file...
  var blob = new Blob([content], { type: "text/xml"});
  formData.append("webmasterfile", blob);
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "");

  if (formData.polyfill) {
      xhr.setRequestHeader("Content-Type", "multipart/form-data; boundary=" + formData.boundary)
      // formData.toString() returns Promise
      formData.toString().then(function(data){
          xhr.send(data);
      })
  } else {
      // normal way
      xhr.send(formData);
  }
```
use with *fetch*.

```javascript
var postData = function(formData){
    if (formData.polyfill) {
        return formData.toString().then(function(data){
            return fetch("", {
                method: "POST",
                headers: {
                    "Content-Type": "multipart/form-data; boundary=" + formData.boundary
                },
                body: data
            })
        })
    } else {
       return fetch("", {
            method: "POST",
            body: datda
       })
    }
}
postData(formData).then(function(res){
  console.log(res)
});
```

## Examples

See examples in [examples](https://github.com/henryluki/FormData/tree/master/examples) directory

## Reference

This project was inspired by these good projects

- [html5-formdata](https://github.com/francois2metz/html5-formdata)
- [fetch](https://github.com/github/fetch)