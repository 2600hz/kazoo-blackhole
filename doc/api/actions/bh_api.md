# Send requests to Crossbar

This API provide a way to send requests to Crossbar (tunneling Crossbar HTTP request through WebSocket) and receive its response later.

## Authorization

Your WebSocket `auth_token` will be used to perform the Crossbar request.

Your `auth_token` requires to have `api:tunnel` scope.

## Request Payload

Key | Description | Type | Default | Required
--- | ----------- | ---- | ------- | --------
`action` | to send request to HTTP API | `string('api')` |  | `true`
`data` | data object | `object()` |  | `true`
`data.verb` | HTTP method to perform (in lower case) | `string()` | `get` | `false`
`data.endpoint` | the HTTP API endpoint URL to use, e.g: `/v2/account/123/users/123` | `string()` |  | `true`
`data.body` | HTTP body data to use | `any()` |  | `false`

For example to send a `GET /v2/accounts/156e05e8a12fd138540cd2017a97e371/users`:

```json
{
    "action": "api",
    "auth_token": "{AUTH_TOKEN}",
    "request_id": "{REQUEST_ID}",
    "data": {
        "verb": "get",
        "endpoint": "/v2/accounts/156e05e8a12fd138540cd2017a97e371/users"
    }
}
```

## Response

`data` is regular Crossbar response for that endpoint:

```json
{
    "action": "reply",
    "request_id": "{REQUEST_ID}",
    "status": "success",
    "data": {
    }
}
```
