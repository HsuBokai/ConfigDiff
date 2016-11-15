BEGIN{
}
/^#/{
	n = split($0, arr, " ");
	if (5 != n) {
		printf("error !!\n");
		exit -1;
	}
	printf("%d %s\n", NR, arr[2]);
}
/^CONFIG_/{
	n = split($0, arr, "=");
	printf("%d %s\n", NR, arr[1]);
}
{
}
END{
}
