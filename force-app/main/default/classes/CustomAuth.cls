global class CustomAuth extends Auth.AuthProviderPluginClass {
          
          // Use this URL for the endpoint that the 
          // authentication provider calls back to for configuration.
          public String redirectUrl = 'https://personalproject6-dev-ed.develop.my.salesforce.com/services/authcallback/SpringLogin2'; 
          private String key;
          private String secret;
          
          // Application redirection to the Concur website for 
          // authentication and authorization.
          private String authUrl;  
          
          // URI to get the new access token from concur using the GET verb.
          private String accessTokenUrl; 
          
          // Api name for the custom metadata type created for this auth provider.
          private String customMetadataTypeApiName = 'AuthProvider__mdt'; 
          
          // Api URL to access the user in Concur
          private String userAPIUrl; 
          
          // Version of the user api URL to access data from Concur
          private String userAPIVersionUrl; 
          
          global String getCustomMetadataType() {
              return customMetadataTypeApiName;
          } 
            
          global PageReference initiate(Map<string,string> 
            authProviderConfiguration, String stateToPropagate) 
            { 
                authUrl = authProviderConfiguration.get('AuthEndpoint__c'); 
                key = authProviderConfiguration.get('ClientId__c'); 

                System.debug('authProviderConfiguration >> ' + authProviderConfiguration);
                
                // Here the developer can build up a request of some sort. 
                // Ultimately, they return a URL where we will redirect the user. 
                String url = authUrl + '?client_id='+ key +'&scope=openid&response_type=code&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate; 
                return new PageReference(url); 
            } 
            
            global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> 
            authProviderConfiguration, Auth.AuthProviderCallbackState state ) 
            { 
                // Here, the developer will get the callback with actual protocol. 
                // Their responsibility is to return a new object called 
                // AuthProviderTokenResponse. 
                // This will contain an optional accessToken and refreshToken 
                key = authProviderConfiguration.get('ClientId__c'); 
                secret = authProviderConfiguration.get('ClientSecret__c'); 
                accessTokenUrl = authProviderConfiguration.get('TokenEndpoint__c'); 
            
                Map<String,String> queryParams = state.queryParameters; 
                String code = queryParams.get('code'); 
                String sfdcState = queryParams.get('state'); 
            
                HttpRequest req = new HttpRequest(); 
                String body = 'grant_type=authorization_code&code=' + code + '&client_id=' + key + '&client_secret=' + secret+ '&redirect_uri=' + redirectUrl; 
                System.debug('body >> ' + body);
                req.setEndpoint(accessTokenUrl);
                req.setBody(body); 
                req.setHeader('Content-Type','application/x-www-form-urlencoded');
                req.setHeader('ngrok-skip-browser-warning', '123456');
                // req.setHeader('Authorization', EncodingUtil.base64Encode(Blob.valueOf(key + ':'+ secret)));
                req.setMethod('POST'); 
            
                Http http = new Http(); 
                HTTPResponse res = http.send(req); 
                String responseBody = res.getBody(); 
                String token = getTokenValueFromResponse(responseBody, 'access_token'); 
            
                return new Auth.AuthProviderTokenResponse('CustomAuth', token, 
                'refreshToken', sfdcState); 
            } 
                       
            global Auth.UserData getUserInfo(Map<string,string> 
            authProviderConfiguration, 
            Auth.AuthProviderTokenResponse response) 
            { 
                //Here the developer is responsible for constructing an 
                //Auth.UserData object 
                String token = response.oauthToken; 
                HttpRequest req = new HttpRequest(); 
                userAPIUrl = authProviderConfiguration.get('UserInfoEndpoint__c'); 
                req.setHeader('Authorization', 'Bearer ' + token); 
                req.setEndpoint(userAPIUrl); 
                req.setHeader('Content-Type','application/json'); 
                req.setHeader('ngrok-skip-browser-warning', '123456');
                req.setMethod('POST'); 
            
                Http http = new Http(); 
                HTTPResponse res = http.send(req); 
                String responseBody = res.getBody(); 
                String id = getTokenValueFromResponse(responseBody, 
                'sub'); 
                return new Auth.UserData(id, null, null, null, 
                id, 'what', null, null, 'CustomAuth', null, null); 
            } 
            
            private String getTokenValueFromResponse(String response, 
            String token) 
            { 
                return (String)((Map<String, Object>)JSON.deserializeUntyped(response)).get(token);
            } 
            
        }