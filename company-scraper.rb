require 'rubygems'
require 'nokogiri'
require 'open-uri'

class CompanyScraper

	def initialize(url, last_company_id)
		@page = Nokogiri::HTML(open(url))
		@last_page = @page.css('div.pagination a.job-link')[-2].text.to_i
		@last_company_id = last_company_id
	end

	def build_urls
		["http://careers.stackoverflow.com/jobs/companies?pg=2"]
			# , "http://careers.stackoverflow.com/jobs/companies?pg=2" ]
		# urls = []
		# (1..5).each {|n| urls << "http://careers.stackoverflow.com/jobs/companies?pg=#{n}"} 
		# urls
	end

	def company_urls
		urls = build_urls
		company_urls = []
		urls.map do |url|
		  page = Nokogiri::HTML(open(url))

		  break if page.css('.list.companies a.title').first['href'].split('/').last == @last_company_id
		  
		  company_urls << page.css('.list.companies a.title').map {|x| "http://careers.stackoverflow.com/uk" + x['href']}
		  company_urls.flatten!
		end
		company_urls
	end

	def posted_at
		Time.now.strftime("%Y-%m-%d %H:%M:%S")
	end

	def get_name
		@page.css('h1').text
	end

	def get_avatar
		@page.css('div.logo-container img').first['src'] rescue nil
	end

	def get_size
		@page.css('table.basics tr').first.children[1].text rescue nil
	end

	def get_status
		@page.css('table.basics tr')[1].children[1].text rescue nil
	end

	def get_founded
		@page.css('table.basics tr')[2].children[1].text.to_i rescue nil
	end

	def get_url
		@page.css('a.cp-links-url').text rescue nil
	end

	def get_tags
		@page.css('div.tags span.post-tag').map(&:text) rescue []
	end

	def get_benefits
		@page.css('div.benefits-list span.benefit').map(&:text) rescue []
	end

	def get_open_jobs
		@page.css('div.job a').map {|link| link[:href][/\d+/]} rescue []
	end

	def scrape
		@company_urls = company_urls
		
		index = 1
		@company_urls.map do |company_url|
			puts "Parsing page #{index}"
			index += 1

		  @page = Nokogiri::HTML(open(company_url))

		    { name: get_name,
		      avatar: get_avatar,
		      size: get_size,
		      status: get_status,
		      founded: get_founded,
		      url: get_url,
		      company_id: company_url.split('/').last,
		      tags: get_tags,
		      benefits: get_benefits,
		      jobs: get_open_jobs,
		      created_at: posted_at
		    }
		end
	end

	def self.scrape_jobs(job_ids)
		job_ids.each do |job_id|
			url = 'http://careers.stackoverflow.com/jobs/' + job_id
			page = Nokogiri::HTML(open(url))
			{
				job_id: job_id,
				title: page.css('h1.title').text,
				description: (""),
				url: url,
				jscore: page.css("h3").match(/\d+(?=\sout)/),
				location: page.css('span.location').text,
				company_name: page.css('a.employer').text,
				tags: [row.css('a.post-tag.job-link').map(&:text)].flatten,
				created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
			}
		end
	end

end


