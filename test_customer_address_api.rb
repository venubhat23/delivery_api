#!/usr/bin/env ruby

# Test script for Customer Address API (using customers table)
# This demonstrates the API endpoints and their expected behavior

require 'net/http'
require 'json'
require 'uri'

BASE_URL = 'http://localhost:3000/api/v1'

def make_request(method, endpoint, data = nil)
  uri = URI("#{BASE_URL}#{endpoint}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  case method.upcase
  when 'GET'
    request = Net::HTTP::Get.new(uri)
  when 'POST'
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = data.to_json if data
  when 'PUT', 'PATCH'
    request = Net::HTTP::Put.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = data.to_json if data
  when 'DELETE'
    request = Net::HTTP::Delete.new(uri)
  end
  
  begin
    response = http.request(request)
    {
      status: response.code,
      body: JSON.parse(response.body)
    }
  rescue JSON::ParserError
    {
      status: response.code,
      body: response.body
    }
  rescue => e
    {
      error: e.message
    }
  end
end

puts "=== Customer Address API Test (Using Customers Table) ==="

# Test data - Note: customer_id should be an existing customer ID
customer_id = 1 # Change this to an existing customer ID
address_data = {
  customer_id: customer_id,
  address_line: "1234 MG Road",
  city: "Bangalore",
  state: "Karnataka",
  postal_code: "560001",
  country: "India",
  phone_number: "9876543210",
  landmark: "Near Garuda Mall",
  full_address: "1234 MG Road, Near Garuda Mall, Bangalore - 560001",
  longitude: 77.5946,
  latitude: 12.9716
}

# 1. Create/Update Address for Customer
puts "\n1. Creating/Updating Address for Customer #{customer_id}..."
puts "POST /api/v1/customer_address"
puts "Data: #{address_data.to_json}"
create_response = make_request('POST', '/customer_address', address_data)
puts "Response: #{create_response}"

if create_response[:status] == '201' || create_response[:status] == '200'
  # 2. Read Address
  puts "\n2. Reading Address for Customer #{customer_id}..."
  puts "GET /api/v1/customer_address/#{customer_id}"
  read_response = make_request('GET', "/customer_address/#{customer_id}")
  puts "Response: #{read_response}"
  
  # 3. Update Address
  puts "\n3. Updating Address for Customer #{customer_id}..."
  update_data = {
    address_line: "4321 Residency Road",
    city: "Bangalore",
    postal_code: "560025",
    landmark: "Opposite to Forum Mall",
    full_address: "4321 Residency Road, Opposite to Forum Mall, Bangalore - 560025",
    longitude: 77.6101,
    latitude: 12.9352
  }
  puts "PATCH /api/v1/customer_address/#{customer_id}"
  puts "Data: #{update_data.to_json}"
  update_response = make_request('PATCH', "/customer_address/#{customer_id}", update_data)
  puts "Response: #{update_response}"
else
  puts "Failed to create/update address. Make sure customer ID #{customer_id} exists."
end

puts "\n=== API Documentation ==="
puts <<~DOC
  
  Customer Address API Endpoints (Using Customers Table):
  
  1. Create/Update Address:
     POST /api/v1/customer_address
     Content-Type: application/json
     
     Request Body:
     {
       "customer_id": 123,
       "address_line": "1234 MG Road",
       "city": "Bangalore",
       "state": "Karnataka",
       "postal_code": "560001",
       "country": "India",
       "phone_number": "9876543210",
       "landmark": "Near Garuda Mall",
       "full_address": "1234 MG Road, Near Garuda Mall, Bangalore - 560001",
       "longitude": 77.5946,
       "latitude": 12.9716
     }
  
  2. Read Address:
     GET /api/v1/customer_address/:customer_id
  
  3. Update Address:
     PUT/PATCH /api/v1/customer_address/:customer_id
     Content-Type: application/json
     
     Request Body (partial update supported):
     {
       "address_line": "4321 Residency Road",
       "city": "Bangalore",
       "postal_code": "560025",
       "landmark": "Opposite to Forum Mall",
       "full_address": "4321 Residency Road, Opposite to Forum Mall, Bangalore - 560025",
       "longitude": 77.6101,
       "latitude": 12.9352
     }
  
  4. Clear Address (optional):
     DELETE /api/v1/customer_address/:customer_id
  
  5. List Customer Addresses (optional):
     GET /api/v1/customer_addresses?customer_id=123
     GET /api/v1/customer_addresses (all customers)
     
  Note: This implementation uses the existing customers table.
  The customer_id in the request body for POST should match an existing customer.
  The :id parameter in the URL refers to the customer ID, not a separate address ID.
DOC