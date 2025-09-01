package tests

import (
	"context"
	"io"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
)

var Python = struct {
	AWS_DEFAULT_REGION              string
	AWS_ECR_PUBLIC_URI              string
	AWS_ECR_PUBLIC_REPOSITORY_GROUP string
	AWS_ECR_PUBLIC_IMAGE_NAME       string
	AWS_ECR_PUBLIC_IMAGE_TAG        string
}{
	AWS_DEFAULT_REGION:              "us-east-1",
	AWS_ECR_PUBLIC_URI:              "public.ecr.aws/dev1-sg",
	AWS_ECR_PUBLIC_REPOSITORY_GROUP: "base",
	AWS_ECR_PUBLIC_IMAGE_NAME:       "python",
	AWS_ECR_PUBLIC_IMAGE_TAG:        "latest",
}

func TestContainersGoPullPython(t *testing.T) {
	ctx := context.Background()
	for attempt := 0; attempt < 3; attempt++ {
		container, e := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
			ContainerRequest: testcontainers.ContainerRequest{
				Image: Python.AWS_ECR_PUBLIC_URI + "/" + Python.AWS_ECR_PUBLIC_REPOSITORY_GROUP + "/" + Python.AWS_ECR_PUBLIC_IMAGE_NAME + ":" + Python.AWS_ECR_PUBLIC_IMAGE_TAG,
			},
		})
		require.NoError(t, e)
		container.Terminate(ctx)
	}
}

func TestContainersGoExecPython(t *testing.T) {
	ctx := context.Background()
	container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: testcontainers.ContainerRequest{
			Image: Python.AWS_ECR_PUBLIC_URI + "/" + Python.AWS_ECR_PUBLIC_REPOSITORY_GROUP + "/" + Python.AWS_ECR_PUBLIC_IMAGE_NAME + ":" + Python.AWS_ECR_PUBLIC_IMAGE_TAG,
			Cmd:   []string{"/bin/bash", "-c", "sleep infinity"},
		},
		Started: true,
	})
	require.NoError(t, err)
	defer container.Terminate(ctx)

	commands := [][]string{
		{"/bin/bash", "-c", "python --version"},
		{"/bin/bash", "-c", "pip --version"},
	}

	for _, cmd := range commands {
		exitCode, reader, err := container.Exec(ctx, cmd)
		require.NoError(t, err)
		require.Equal(t, 0, exitCode)

		output, err := io.ReadAll(reader)
		require.NoError(t, err)

		t.Logf("Command: %v\nOutput: %s\n", cmd, output)
		require.NotEmpty(t, output)
	}
}
