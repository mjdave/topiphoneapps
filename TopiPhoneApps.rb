
@knownRegionsToTopHundreds = 
{
    'United States'             => 25204,
    # doesn't work right, not sure why 'Argentina'                 => 25129,
    'Australia'                 => 25211,
    'Canada'                    => 25208,
    'Denmark'                   => 25207,
    'Deutschland'               => 25210,
    'Espana'                    => 25207,
    'Finland'                   => 25207,
    'France'                    => 25205,
    'Greece'                    => 25207,
    'Hong Kong'                 => 25129,
    'India'                     => 25129,
    'Italia'                    => 25207,
    'Ireland'                   => 25207,
    'Israel'                    => 25129,
    'Lebanon'                   => 25129,
    'Mexico'                    => 25129,
    'New Zealand'               => 25211,
    'Norway'                    => 25207,
    'Russia'                    => 25129,
    'United Kingdom'            => 25206,
    'Japan'                     => 25209
}

#no books?
@categoryOffsets = 
{
    'Top Paid'              => 0,
    'Business'              => -56,
    'Education'             => -48,
    'Entertainment'         => -40,
    'Finance'               => -32,
    'Games'                 => -24,
    'Health & Fitness'      => -16,
    'Lifestyle'             => -8,
    'Music'                 => 8,
    'Navigation'            => 16,
    'News'                  => 24,
    'Photography'           => 32,
    'Productivity'          => 40,
    'Reference'             => 48,
    'Social Networking'     => 56,
    'Sports'                => 64,
    'Travel'                => 72,
    'Utilities'             => 80,
    'Weather'               => 88
    }
    #'Word'                 => 981   nope  1005 is the genre offset from games, but doesn't work



@region_codes = {
'United States'           => 143441,
'Argentina'               => 143505,
'Australia'               => 143460,
'Belgium'                 => 143446,
'Brazil'                  => 143503,
'Canada'                  => 143455,
'Chile'                   => 143483,
'China'                   => 143465,
'Colombia'                => 143501,
'Costa Rica'              => 143495,
'Croatia'                 => 143494,
'Czech Republic'          => 143489,
'Denmark'                 => 143458,
'Deutschland'             => 143443,
'El Salvador'             => 143506,
'Espana'                  => 143454,
'Finland'                 => 143447,
'France'                  => 143442,
'Greece'                  => 143448,
'Guatemala'               => 143504,
'Hong Kong'               => 143463,
'Hungary'                 => 143482,
'India'                   => 143467,
'Indonesia'               => 143476,
'Ireland'                 => 143449,
'Israel'                  => 143491,
'Italia'                  => 143450,
'Korea'                   => 143466,
'Kuwait'                  => 143493,
'Lebanon'                 => 143497,
'Luxembourg'              => 143451,
'Malaysia'                => 143473,
'Mexico'                  => 143468,
'Nederland'               => 143452,
'New Zealand'             => 143461,
'Norway'                  => 143457,
'Osterreich'              => 143445,
'Pakistan'                => 143477,
'Panama'                  => 143485,
'Peru'                    => 143507,
'Phillipines'             => 143474,
'Poland'                  => 143478,
'Portugal'                => 143453,
'Qatar'                   => 143498,
'Romania'                 => 143487,
'Russia'                  => 143469,
'Saudi Arabia'            => 143479,
'Schweitz/Suisse'         => 143459,
'Singapore'               => 143464,
'Slovakia'                => 143496,
'Slovenia'                => 143499,
'South Africa'            => 143472,
'Sri Lanka'               => 143486,
'Sweden'                  => 143456,
'Taiwan'                  => 143470,
'Thailand'                => 143475,
'Turkey'                  => 143480,
'United Arab Emirates'    => 143481,
'United Kingdom'          => 143444,
'Venezuela'               => 143502,
'Vietnam'                 => 143471,
'Japan'                   => 143462
}

if ARGV[0] != nil then
    app = ARGV[0]
    if app.to_i != 0 then
        @appID = app.to_i
    else
        @appName = app
    end
    
    if ARGV[1] != nil then
        @categoryName = ARGV[1].to_s
    end
else

    puts "Usage: ruby top100.rb appID/appName [categoryName]
    appID is the ID of the application you are interested in. Alternatively use the exact name of your app (with escaped spaces or in single quotes).
    categoryName is an optional name to give only your apps ranking in the top paid within that category eg. 'Health & Fitness'"
          exit(0)
end


def unescapeHTML(string)
  str = string.dup
  str.gsub!(/&(.*?);/n) {
    match = $1.dup
    case match
    when /\Aamp\z/ni           then '&'
    when /\Aquot\z/ni          then '"'
    when /\Agt\z/ni            then '>'
    when /\Alt\z/ni            then '<'
    when /\A#(\d+)\z/n         then Integer($1).chr
    when /\A#x([0-9a-f]+)\z/ni then $1.hex.chr
    end
  }
  str
end

def printStatsForRegionAndID(regionName, categoryName, category)
    result = nil
    

    datastring = String.new()
    IO.popen("curl -s -A \"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2)\" -H \"X-Apple-Store-Front: #{regionName}-1\" 'http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wa/viewTop?id=#{category}&popId=30' | gunzip") {|d| datastring += d.read}
    
    
    returnedName = datastring.match(/pageName=(.*)&amp;pccr=/)
    
    if returnedName and returnedName[1]
        return "#{regionName} - #{category} - #{categoryName} - #{unescapeHTML(returnedName[1])}"
    else
        return "#{regionName} - #{category} - #{categoryName} - No Match"
    end
end

def scanCategories
    @knownRegionsToTopHundreds.each do |regionName, topHundredCategory|
        @categoryOffsets.each do |categoryName, categoryID|
            puts printStatsForRegionAndID(regionName, categoryName, topHundredCategory + categoryID)
        end
    end
end

def printStatsForRegion(regionName, categoryName, topPaid, specificCategory)
    result = {}
    

    regionID = @region_codes[regionName]
    datastring = String.new()
    
    categoriesToFetch = [topPaid]
    categoriesToFetch << specificCategory if specificCategory != topPaid
    
    categoriesToFetch.each do |category|
      datastring = String.new()
      IO.popen("curl -s -A \"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2)\" -H \"X-Apple-Store-Front: #{regionID}-1\" 'http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wa/viewTop?id=#{category}&popId=30' | gunzip") {|d| datastring += d.read}
    
    
      #categoryNameFound = datastring.match(/pageName=(.*)&amp;pccr=/)[1]
    
      buys = datastring.scan(/\<Buy.*\>/)
    
      found = false
      buys.each_with_index do |value, index|
          #puts "index #{index} is value is #{value} " 
          title = value.match(/itemName="(.*)"/)
          if title then
              match = nil
              if @appID then 
                  itemID = value.match(/salableAdamId=(\d+)&amp/)[1].to_i
                  match = @appID == itemID
              elsif @appName then
                  match = title[1].match(/#{@appName}/)
              end
            
              if match then
                  result['regionName'] = regionName
                  result['appName'] = unescapeHTML(title[1])
                  if(category == topPaid) 
                    result['topPaid'] = (index + 1).to_s
                  else
                    result['rank'] = (index + 1).to_s
                  end  
                  found = true
                  break
              end
          end
      end
    
      if !found then
          result['regionName'] = regionName
          if(category == topPaid) 
            result['topPaid'] = "NR"
          else
            result['rank'] = "NR"
          end  
      end
    end
    
    result
end

def saveStuff(array_or_hash)
    
end

def main
    
    categoryName = "Top Paid"
    categoryOffset = 0
    
    if @categoryName != nil then
        if @categoryOffsets[@categoryName] then
            categoryName = @categoryName
            categoryOffset = @categoryOffsets[@categoryName]
        else
            puts "unknown category: #{@categoryName}"
            exit(0)
        end
    end
    
    threads = []
    @knownRegionsToTopHundreds.each do |regionName, topPaidCategoryID|
        #this hackyOffset thing is because the category offset is incorrect in the 25129 offset. Works for games, untested otherwise
        hackyOffset = 0
        if categoryOffset != 0 and topPaidCategoryID == 25129 then
            hackyOffset = 29
        end
        specificCategoryID = topPaidCategoryID + categoryOffset + hackyOffset
        threads << Thread.new {printStatsForRegion(regionName, categoryName, topPaidCategoryID, specificCategoryID)}
    end
    
    results = []

    threads.each do |thread|
        results << thread.value
    end
    
    appName = @appName
    
    if appName == nil then
        results.each do |result|
            if result['appName'] then
                appName = result['appName']
                break
            end
        end
    end
    
    title = ""
    
    if appName then
        title = appName
    else
        title = "App: #{@appID}"
        appName = @appID.to_s
    end
    
    puts "\n****** #{title} - #{categoryName} ******"
    puts "\e[1mRegion\e[0m               \e[1mRank\e[0m  \e[1mChange\e[0m"
    
    orderedRegions = @region_codes.keys.sort do |a, b|
        a.casecmp(b)
    end
    
    orderedResults = []
    orderedRegions.each do |rc_key|
        results.each do |result|
            if result['regionName'] == rc_key then
                orderedResults << result
            end
        end
    end
    
    oldStats = nil
    
    begin
        inputFile = File.new("top100LatestStats_#{categoryName}_#{appName}.txt", 'r')
        oldStats = Marshal.load(inputFile.read)
    rescue
    end
    
    outputFile = File.new("top100LatestStats_#{categoryName}_#{appName}.txt", File::CREAT|File::TRUNC|File::RDWR)
    outputFile << Marshal.dump(orderedResults)
    outputFile.close
    
    prettyResults = []
    orderedResults.each_with_index do |result, index|
        regionTitle = "#{result['regionName']} "
        while regionTitle.length < 20 do
            regionTitle = regionTitle + "_"
        end
        
        
        topPaidRank = result['topPaid']
        noTopPaidRank = topPaidRank == "NR"
        topPaidRank = topPaidRank + " "
        while topPaidRank.length < 5 do
            topPaidRank = topPaidRank + "_"
        end
        
        if @categoryName != nil
          rank = result['rank']
          noRank = rank == "NR"
          rank = rank + " "
          while rank.length < 5 do
              rank = rank + "_"
          end
        end  
        
        oldStatsValue = "\e[33m+0\e[0m"
        if oldStats then
            if oldStats[index]['regionName'] == result['regionName'] then
              if @categoryName != nil
                oldRank = oldStats[index]['rank']

                if oldRank then
                    if oldRank == "NR" then
                        if result['rank'] == "NR" then
                            oldStatsValue = "\e[33m+0\e[0m"
                        else
                            oldStatsValue = "\e[32m+#{100 - result['rank'].to_i} (++)\e[0m"
                        end
                    elsif result['rank'] == "NR" then
                        oldStatsValue = "\e[31m#{oldRank.to_i - 100} (--)\e[0m"
                    elsif oldRank.to_i < result['rank'].to_i then
                        oldStatsValue = "\e[31m#{oldRank.to_i - result['rank'].to_i}\e[0m"
                    elsif oldRank.to_i > result['rank'].to_i then
                        oldStatsValue = "\e[32m+#{oldRank.to_i - result['rank'].to_i}\e[0m"
                    else
                        oldStatsValue = "\e[33m+0\e[0m"
                    end
                end
              end
                
                
                oldTopPaid = oldStats[index]['topPaid']
                 if oldTopPaid then
                      if oldTopPaid == "NR" then
                          if result['topPaid'] == "NR" then
                              oldTPStatsValue = "\e[33m+0\e[0m"
                          else
                              oldTPStatsValue = "\e[32m+#{100 - result['topPaid'].to_i}\e[0m"
                          end
                      elsif result['topPaid'] == "NR" then
                          oldTPStatsValue = "\e[31m#{100 - oldTopPaid.to_i}\e[0m"
                      elsif oldTopPaid.to_i < result['topPaid'].to_i then
                          oldTPStatsValue = "\e[31m#{oldTopPaid.to_i - result['topPaid'].to_i}\e[0m"
                      elsif oldTopPaid.to_i > result['topPaid'].to_i then
                          oldTPStatsValue = "\e[32m+#{oldTopPaid.to_i - result['topPaid'].to_i}\e[0m"
                      else
                          oldTPStatsValue = "\e[33m+0\e[0m"
                      end
                  end
                
            end
        end
        
        if (@categoryName != nil && !noRank) || !noTopPaidRank then
          resultToPrint = "#{regionTitle}"
          resultToPrint += " \e[32m#{rank}\e[0m #{oldStatsValue} " unless @categoryName == nil
          resultToPrint += "      Top Paid:" unless @categoryName == nil or noTopPaidRank 
          resultToPrint += " \e[32m#{topPaidRank}\e[0m #{oldTPStatsValue}" unless noTopPaidRank
          prettyResults << resultToPrint
        end
    end
    
    prettyResults.each do |printResult|
        puts printResult
    end
    
    puts ""
    
end

main
#scanCategories

