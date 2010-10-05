if  FileTest.exists?("/usr/bin/dpkg")
	Facter.add("debian_arch") do
		setcode do
			%x{/usr/bin/dpkg --print-architecture}
		end
	end
end
