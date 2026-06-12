# rhode-data-analyst
hw3 solution by Kazmina Aleksandra BBI2503
анализ данных о продуктах бренда rhode от hailey bieber

## commands

| command | description |
|---------|-------------|
| `./run.sh build_generator` | build generator image |
| `./run.sh run_generator` | generate data/data.csv |
| `./run.sh create_local_data` | generate data locally (local_data/) |
| `./run.sh build_reporter` | build reporter image |
| `./run.sh run_reporter` | create data/report.html |
| `./run.sh structure` | show project structure |
| `./run.sh clear_data` | clean data folder |
| `./run.sh inside_generator` | enter generator container |
| `./run.sh inside_reporter` | enter reporter container |
| `./run.sh report_server` | start web server |

## instructions for codespaces

1. run `./run.sh build_generator && ./run.sh run_generator`
2. run `./run.sh build_reporter && ./run.sh run_reporter`
3. run `./run.sh report_server`
4. open the ports tab in codespaces
5. find port 8080
6. click on the icon of planet (or sphere)
7. add `/report.html` to the end of the url

## project structure

```
.
├── data/                  # generated data and report
│   ├── data.csv
│   └── report.html
├── local_data/            # locally generated data
├── Dockerfile.generator   # generator image
├── Dockerfile.reporter    # reporter image
├── generate.py            # data generation script
├── run.sh                 # main script
└── README.md
```