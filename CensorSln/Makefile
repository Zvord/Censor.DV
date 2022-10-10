.PHONY: all clean

publish:
	dotnet publish src/Censor --configuration=Release --output=./bin/

clean:
	dotnet clean
	rm -r ./bin/*

#	dotnet publish src/Censor -p:PublishSingleFile=true --configuration=Release --output=./bin/ -r osx.12-arm64