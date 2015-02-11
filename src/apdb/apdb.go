package apdb

import (
	_ "github.com/lib/pq"
	"bufio"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"math"
	"net"
	"net/http"
	"os"
        "strings"
	"strconv"
        "time"
)

func DB_setup_psql(db_name string, db_user string) {
	var db	*sql.DB
	var err	error

	db, err = sql.Open("postgres", "dbname = postgres sslmode=disable")
	if err != nil {
		log.Fatal(err)
		return
	}

	_, err = db.Query("DROP USER " + db_user)
	/* Result Ignored */

	_, err = db.Query("CREATE USER " + db_user + " NOCREATEDB NOCREATEROLE")
	if err != nil {
		log.Fatal(err)
		return
	}

	_, err = db.Query("CREATE DATABASE " + db_name + " OWNER = " + db_user + " ENCODING = 'UTF-8' TEMPLATE template0")
	if err != nil {
		log.Fatal(err)
		return
	}

	/* Modify pg_hba.conf */
}

func DB_setup_schema(db_name string, db_user string, schemafilename string) {
	var db		*sql.DB
	var query	string

	file, err := os.Open(schemafilename)
	if err != nil {
		file, err = os.Open("db_schemas/" + schemafilename)
		if err != nil {
			file, err = os.Open("/usr/share/acs/" + schemafilename)
			if err != nil {
				log.Fatal(err)
				return
			}
		}
	}
	defer file.Close()

	db, err = sql.Open("postgres", "user=" + db_user + " dbname=" + db_name + " sslmode=disable")
	if err != nil {
		log.Fatal(err)
		return
	}

	query = ""
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()

		if len(line) == 0 || line[0] == '#' {
			continue
		}

		query += line;

		if line[len(line)-1] != ';' {
			continue
		}

		_, err := db.Query(query);
		if err != nil {
			fmt.Println(query)
			log.Fatal(err)
			return
		}

		query = ""
	}

	/* The last query */
	if query != "" {
		_, err := db.Query(query);
		if err != nil {
			fmt.Println(query)
			log.Fatal(err)
			return
		}
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	log.Println("Setup DB - done")
}

