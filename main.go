package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"
)

type Comic struct {
	Num   int    `json:"num"`
	Link  string `json:"link"`
	Img   string `json:"img"`
	Title string `json:"title"`
}

const baseXkcdURL = "https://xkcd.com/%d/info.0.json"

func getComic(comicID int) (comic *Comic, err error) {
	url := fmt.Sprintf(baseXkcdURL, comicID)
	response, err := http.Get(url)
	if err != nil {
		return nil, err
	}

	err = json.NewDecoder(response.Body).Decode(&comic)
	if err != nil {
		return nil, err
	}

	return comic, nil
}

// concurrent
func main() {
	nonConcurrent()
	concurrent()
}

// non concurrent
func nonConcurrent() {
	start := time.Now()
	defer func() {
		fmt.Println("Execution Time: ", time.Since(start))
	}()

	comicsNeeded := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	comicMap := make(map[int]*Comic, len(comicsNeeded))

	for _, id := range comicsNeeded {
		comic, err := getComic(id)
		if err != nil {
			continue
		}
		comicMap[id] = comic
		fmt.Printf("Fetched comic %d with title %v\n", id, comic.Title)
	}
}

// concurrent
func concurrent() {
	start := time.Now()
	defer func() {
		fmt.Println("Execution Time: ", time.Since(start))
	}()

	comicsNeeded := []int{11, 22, 33, 44, 55, 66, 77, 88, 99, 100}
	comicMap := make(map[int]*Comic)
	wg := sync.WaitGroup{}

	for _, id := range comicsNeeded {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()

			comic, err := getComic(id)

			if err != nil {
				return
			}

			comicMap[id] = comic
			fmt.Printf("Fetched comic %d with title %v\n", id, comic.Title)
		}(id)
	}

	wg.Wait()
}
