#include <stdio.h>
#include <stdlib.h>
int main(int argc, char* argv[])
{
	char* arguments[] = { argv[1], NULL }; 
	char buffer[BUFSIZ];
	if (argc > 1) {
		sprintf(buffer, "./proot -R ./ ./dash ./run.sh %s", arguments[0]);
		system(buffer);
	} else {
		sprintf(buffer, "./proot -R ./ ./dash ./run.sh");
		system(buffer);
		}
}

