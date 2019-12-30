//
//  LocationSearchTable.swift
//  MapTry
//
//  Created by JOEL CRAWFORD on 30/12/2019.
//  Copyright © 2019 RedTokens. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var matchingItems:[MKMapItem] = [] //stash search results for easy access.
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    
    //====This method converts the placemark to a custom address format like: “4 Melrose Place, Washington DC”.===
       
       func parseAddress(selectedItem:MKPlacemark) -> String {
           // put a space between "4" and "Melrose Place"
           let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
           // put a comma between street and city/state
           let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
           // put a space between "Washington" and "DC"
           let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
           let addressLine = String(
               format:"%@%@%@%@%@%@%@",
               // street number
               selectedItem.subThoroughfare ?? "",
               firstSpace,
               // street name
               selectedItem.thoroughfare ?? "",
               comma,
               // city
               selectedItem.locality ?? "",
               secondSpace,
               // state
               selectedItem.administrativeArea ?? ""
           )
           return addressLine
       }


}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //Setting up the API call
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
    

}

extension LocationSearchTable {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        //getting postal address
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}


extension LocationSearchTable {
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}
