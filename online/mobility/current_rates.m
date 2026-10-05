function rate = current_rates(server_info, collection_UAV_location)
%CURRENT_RATES  A2A transmission rate of every UAV server at its current position.
%
%   RATE = CURRENT_RATES(SERVER_INFO, COLLECTION_UAV_LOCATION) returns a 1-by-N vector with
%   the rate (Eq. (2)) between the collection UAV and each server, using the bandwidth and
%   power of the server type (columns 7 and 4 of SERVER_INFO).
%
%   Used when the swarm is (re)initialised (tau = 1, 51, ...), where PSO-CEMA has not yet
%   positioned the servers, so that LDF-DPTAA still sees the actual link quality. Without it the
%   rate would be zero and GETREWARD would switch to a differently scaled formula for that tau.
%
%   See also TRANSMISSION_RATE, PSO_UPDATE_LOCATION, GETREWARD.

num_of_servers = size(server_info, 1);
rate = zeros(1, num_of_servers);

for server_id = 1:num_of_servers
    distance = norm(server_info(server_id, 2:3) - collection_UAV_location);
    rate(server_id) = transmission_rate(distance, server_info(server_id, 7), server_info(server_id, 4));
end
end
