## Flutter Specifics

-   **Flutter Version:** 3.32.1
-   **Dart Version:** 3.8.1
-   **DevTools Version:** 2.45.1
-   **Android Platform:** android-35, build-tools 35.0.0 (27.0.12077973)
-   **Java Version:** Java(TM) SE Runtime Environment (build 17.0.12+8-LTS-286)
-   **Supported Platforms:** Android, iOS

## Backend Setup

### Docker, for Duckling

-   Ensure you have Docker installed on your machine. If not, download and install it from [here](https://www.docker.com/products/docker-desktop/).
-   run docker

```bash
docker run -p 8000:8000 rasa/duckling
```

### Rasa

-   Open the `backend` directory in your terminal.
-   create a conda environment with with pyhton 3.9

```bash
conda create -n voice_reminder python=3.9
conda activate voice_reminder
```

-   Install the required packages:

```bash
pip install rasa
```

-   train the model:

```bash
rasa train
```

-   Start the Rasa server:

```bash
rasa run --enable-api --cors "*"
```

<br>
<br>
With Everything set up, you can now run the Flutter application and interact with the backend.
