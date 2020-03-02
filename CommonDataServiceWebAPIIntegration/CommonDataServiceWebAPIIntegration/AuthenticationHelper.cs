using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace CommonDataServiceWebAPIIntegration
{
    public class AuthenticationHelper
    {
        public string ClientId { get; set; }
        public string ClientSecret { get; set; }
        public string Dynamics365Url { get; set; }
        public string Dynamics365WebAPIUrl { get; set; }


        public AuthenticationHelper(IConfiguration configuration)
        {
            this.ClientId = configuration.GetValue<string>("AzureAd:ClientId");
            this.ClientSecret = configuration.GetValue<string>("AzureAd:ClientSecret");
            this.Dynamics365Url = configuration.GetValue<string>("AzureAd:Dynamics365Url");
            this.Dynamics365WebAPIUrl = configuration.GetValue<string>("AzureAd:Dynamics365WebAPIUrl");
        }

        public WhoAmIModel Authenticatate()
        {
            ClientCredential clientCredential = new ClientCredential(ClientId, ClientSecret);
            AuthenticationParameters authParameters = AuthenticationParameters.CreateFromResourceUrlAsync(new Uri(Dynamics365WebAPIUrl)).Result;
            var authContext = new AuthenticationContext(authParameters.Authority, false);

            AuthenticationResult result = authContext.AcquireTokenAsync(Dynamics365Url, clientCredential).GetAwaiter().GetResult();

            string token = result.AccessToken;

            return Execute(token);
        }

        private WhoAmIModel Execute(string Token)
        {
            var authHeader = new AuthenticationHeaderValue("Bearer", Token);

            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri(Dynamics365WebAPIUrl);
                client.DefaultRequestHeaders.Authorization = authHeader;

                var response = client.GetAsync("WhoAmI").Result;

                if (response.IsSuccessStatusCode)
                {
                    //Get the response content and parse it.  
                    JObject body = JObject.Parse(response.Content.ReadAsStringAsync().Result);

                    //var jsonString = await task.Content.ReadAsStringAsync();
                    var model = JsonConvert.DeserializeObject<WhoAmIModel>(body.ToString());

                    return model;

                }
                else
                {
                    return new WhoAmIModel { ErrorDetails = response.ReasonPhrase };
                }
            }
        }
    }

    public class WhoAmIModel
    {
        public string BusinessUnitId { get; set; }
        public string OrganizationId { get; set; }
        public string UserId { get; set; }
        public string ErrorDetails { get; set; }

    }
}
