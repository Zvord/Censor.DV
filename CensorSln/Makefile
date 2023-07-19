ifdef ARCH
	ARCH_FLAG=-r $(ARCH)
endif

.PHONY: all clean

publish:
	dotnet publish src/Censor --configuration=Release --output=./bin/ $(ARCH_FLAG)

clean:
	dotnet clean
	rm -r ./bin/*

#	dotnet publish src/Censor -p:PublishSingleFile=true --configuration=Release --output=./bin/ -r osx.12-arm64