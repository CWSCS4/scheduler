#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/*
 *Written by Alex Grant.
 */
char *cat( char **ss, int sslen ) {
  int i;
  char *s;
  s = (char *) calloc( 256, sizeof( char ) );
  for( i = 0; i < sslen; i++ ) {
    strncat( s, ss[i], 256 );
  }
  return s;
}

int main() {
  FILE *f = fopen( "spec.spc", "r" );
  if( f == NULL ) {
    perror( "schedule" );
    exit( -1 );
  }
  /* Generate Specification */
  char spec_args[256];
  while( ( fgets( spec_args, 256, f ) )[0] == '#' );
  spec_args[strlen( spec_args ) - 1] = '\0';
  printf( "%s\n", spec_args );
  char spec_file[256];
  while( ( fgets( spec_file, 256, f ) )[0] == '#' );
  spec_file[strlen( spec_file ) - 1] = '\0';
  printf( "%s\n", spec_file );
  char *gen_spec[] = { "java org.commschool.scheduler.GenerateSpecification ",
		       spec_args,
		       " > ",
		       spec_file };
  char *s = cat( gen_spec, 4 );
  system( s );
  free( s );
  /* Generate an initial schedule */
  char init_file[256];
  while( ( fgets( init_file, 256, f ) )[0] == '#' );
  init_file[strlen( init_file ) - 1] = '\0';
  printf( "%s\n", init_file );
  char *init_args[] = { "generateInitialSchedule -s ",
			spec_file,
			" > ",
			init_file };
  char *s1 = cat( init_args, 4 );
  system( s1 );
  free( s1 );
  /* Print the schedule */
  char sch_out[256];
  while( ( fgets( sch_out, 256, f ) )[0] == '#' );
  sch_out[strlen( sch_out ) - 1] = '\0';
  printf( "%s\n", sch_out );
  char *print_args[] = { "printSchedule -s ",
			 spec_file,
			 " -t ",
			 init_file,
			 " > ",
			 sch_out };
  char *s2 = cat( print_args, 6 );
  system( s2 );
  free( s2 );
  /* Run simulatedAnnealing */
  char simAnn_args[256];
  while( ( fgets( simAnn_args, 256, f ) )[0] == '#' );
  simAnn_args[strlen( simAnn_args ) - 1] = '\0';
  printf( "%s\n", simAnn_args );
  char final[256];
  while( ( fgets( final, 256, f ) )[0] == '#' );
  final[strlen( final ) - 1] = '\0';
  printf( "%s\n", final );
  char *simAnn[] = { "simulatedAnnealing ",
		     simAnn_args,
		     " -s ",
		     spec_file,
		     " -t ",
		     init_file,
		     " -o ",
		     final };
  char *s3 = cat( simAnn, 8 );
  printf( "Press Control-C to interrupt\n" );
  system( s3 );
  free( s3 );
  return 0;
}
