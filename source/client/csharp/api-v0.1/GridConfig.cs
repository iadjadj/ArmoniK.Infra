using System;
using System.IO;
using Newtonsoft.Json.Linq;
using System.Text.Json;

namespace HTCGrid
{
    public class  GridConfig {

        public GridConfig() {
        }

        public void Init(JsonDocument parsedConfiguration) {
            JsonElement root = parsedConfiguration.RootElement;
            this.grid_storage_service = root.GetProperty("grid_storage_service").GetString();
            this.redis_url = root.GetProperty("redis_url").GetString();
            this.private_api_gateway_url = root.GetProperty("private_api_gateway_url").GetString();
            this.api_gateway_key = root.GetProperty("api_gateway_key").GetString();
            this.redis_with_ssl = root.GetProperty("redis_with_ssl").GetString().ToLower();
            this.redis_port = root.GetProperty("redis_port").GetString();
			this.connection_redis_timeout = root.GetProperty("connection_redis_timeout").GetString();
        }

        public string grid_storage_service;
        public string redis_url;
        public string private_api_gateway_url;
        public string api_gateway_key;
        public string redis_with_ssl;
		public string redis_port;
		public string connection_redis_timeout;
    }
}