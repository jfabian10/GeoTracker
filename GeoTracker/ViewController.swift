//
//  ViewController.swift
//  GeoTracker
//
//  Created by CS3714 on 11/9/16.
//  Copyright © 2016 Jesus Fabian. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, MKMapViewDelegate, MKAnnotation {

    @IBOutlet var mapView: MKMapView!
    /*
     
     "The MKPolyline class represents a shape consisting of one or more points that define connecting line segments.
     
     The points are connected end-to-end in the order they are provided. The first and last points are not connected
     
     to each other." [Apple]
     
     */
    
    
    
    // Instance variable to hold the object reference of an object instantiated from the MKPolyline class
    
    var tripTrack: MKPolyline?
    
    
    
    /*
     
     The MKPolylineRenderer class provides the visual representation for an MKPolyline overlay object. This renderer strokes
     
     the line only; it does not fill it. You can change the color and other drawing attributes of the polygon by modifying the
     
     properties inherited from the parent class. You typically use this class as is and do not subclass it." [Apple]
     
     */
    
    
    
    // Instance variable to hold the object reference of an object instantiated from the MKPolylineRenderer class
    
    var tripTrackRenderer: MKPolylineRenderer?
    
    
    
    // Create and initialize an array to contain all annotation objects
    
    var mapAnnotations = [MapAnnotation]()
    
    
    
    // Create and initialize a rectangular area to bound all of the tracks
    
    var trackBoundingBox: MKMapRect = MKMapRectMake(0.0, 0.0, 320.0, 320.0)
    
    
    
    // Required MKAnnotation protocol property "coordinate" defines the center point (specified as a map coordinate) of the annotation.
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
    
    
    
    /*
     
     -----------------------
     
     MARK: - View Life Cycle
     
     -----------------------
     
     */
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        
        
        // Set the map type to hybrid view
        
        mapView.mapType = .hybrid
        
        
        
        // Create the trip track overlay
        
        createTripTrack()
        
        
        
        if tripTrack != nil {
            
            
            
            // Trip track is successfully created
            
            
            
            // Add the tripTrack overlay object to the map view
            
            mapView.add(tripTrack!)
            
            
            
            // Change the currently visible portion of the map and animate the change
            
            mapView.setVisibleMapRect(trackBoundingBox, animated: true)
            
            
            
        } else {
            
            // Trip track could not be created
            
            showErrorMessage(title: "Unable to Create Trip Track!",
                             
                             message: "Something went wrong and a trip track could not be created!")
            
            
            
            return
            
        }
        
    }
    
    
    
    // Add map annotations after the view appears
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        mapView.addAnnotations(mapAnnotations)
        
    }
    
    
    
    /*
     
     --------------------------------
     
     MARK: - Create Trip Track Method
     
     --------------------------------
     
     */
    
    
    
    // Creates the trip track as an MKPolyline overlay
    
    func createTripTrack() {
        
        
        
        //--------------------------
        
        // Local Variables
        
        //--------------------------
        
        
        
        // A waypoint is a reference point in physical space used for navigation purposes
        
        var waypoints = [String]()
        
        
        
        // Upper right corner map point of the box to bound all of the tracks
        
        var upperRightCorner: MKMapPoint = MKMapPointMake(0.0, 0.0)
        
        
        
        // Lower left corner map point of the box to bound all of the tracks
        
        var lowerLeftCorner: MKMapPoint = MKMapPointMake(0.0, 0.0)
        
        
        
        // Used for counting every 50th waypoint to display on the map as a green pin
        
        var count = 1
        
        
        
        /*
         
         TrackData.csv is a comma-separated values (CSV) plain text file that resides in the app's main bundle.
         
         Under the Unix OS (e.g., iOS, MacOS), a file is created as a string of characters.
         
         The String variable trackDataFileContents holds the entire contents of the TrackData.csv file.
         
         */
        
        let trackDataFilePath: String? = Bundle.main.path(forResource: "TrackData", ofType: "csv")
        
        
        
        do {
            
            /*
             
             TRY obtaining the contents of the TrackData.csv file. If an exception (error) is thrown,
             
             execute the code under the CATCH section below.
             
             */
            
            let trackDataFileContents = try NSString(contentsOfFile: trackDataFilePath!, encoding: String.Encoding.utf8.rawValue)
            
            
            
            // The TrackData.csv file is successfully obtained.
            
            
            
            /*
             
             The TrackData.csv file consists of lines formed by the newline "\n" characters.
             
             Each line represents the following data for a waypoint: Date Time Speed Direction, Longitude, Latitude, Altitude
             
             Kth element of the waypoints array contains the Kth line of the track data file, where K=0,1,2,3, ..., 643
             
             
             
             The method components(separatedBy: .newlines) returns an array containing substrings (i.e., the waypoints)
             
             from trackDataFileContents that have been divided by the newline "\n" characters.
             
             */
            
            
            
            waypoints = trackDataFileContents.components(separatedBy: .newlines)
            
            
            
        } catch let error as NSError {
            
            
            
            // Error occurred in obtaining the TrackData.csv file.
            
            
            
            showErrorMessage(title: "Unable to Access the TrackData.csv File!",
                             
                             message: "Error occurred in reading TrackData.csv: \(error.localizedDescription)")
            
            
            
            return
            
        }
        
        
        
        // Determine the number of waypoints
        
        let numberOfWaypoints = waypoints.count;
        
        
        
        // Create an array of objects of type MKMapPoint
        
        var arrayOfMapPoints = [MKMapPoint]()
        
        
        
        for j in 0..<numberOfWaypoints {
            
            
            
            // Obtain the current jth waypoint string corresponding to a line in the track data file
            
            let waypoint: String = waypoints[j]
            
            
            
            // Store the comma­-separated components of the waypoint string into the array waypointData
            
            var waypointData: Array = waypoint.components(separatedBy: ",")
            
            
            
            /*
             
             waypointData[0] ­­= date, time, speed, and direction
             
             waypointData[1] ­­= longitude
             
             waypointData[2] ­­= latitude
             
             waypointData[3] = altitude
             
             */
            
            
            
            // Obtain longitude and latitude as Double values
            
            let longitude:  CLLocationDegrees = NSString(string: waypointData[1]).doubleValue
            
            let latitude:   CLLocationDegrees = NSString(string: waypointData[2]).doubleValue
            
            
            
            // A map coordinate is a latitude and longitude on the spherical representation of the Earth.
            
            // Create a map coordinate using latitude and longitude values.
            
            let mapCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            
            
            
            // After every 50 waypoints, create an annotation object and add it to the array mapAnnotations
            
            if j == count * 50 {
                
                
                
                count += 1   // count = count + 1
                
                
                
                // Compose the altitude subtitle
                
                let altitudeSubtitle = "Altitude = \(waypointData[3])"
                
                
                
                // Instantiate a map annotation object with title waypointData[0] and subtitle altitudeSubtitle at mapCoordinate
                
                let mapAnnotation = MapAnnotation(coordinateGiven: mapCoordinate, titleGiven: waypointData[0], subtitleGiven: altitudeSubtitle)
                
                
                
                // Append the newly created map annotation object to the array of map annotation objects
                
                mapAnnotations.append(mapAnnotation)
                
            }
            
            
            
            // A map point is an x and y value on the Mercator map projection.
            
            // Convert the map coordinate to a map point, which is a Struct with mapPoint.x and mapPoint.y
            
            let mapPoint: MKMapPoint = MKMapPointForCoordinate(mapCoordinate)
            
            
            
            // Compute the current values of upperRightCorner and lowerLeftCorner of the bounding box
            
            if j == 0 {
                
                upperRightCorner = mapPoint
                
                lowerLeftCorner = mapPoint
                
            }
                
            else {
                
                if mapPoint.x > upperRightCorner.x {
                    
                    upperRightCorner.x = mapPoint.x
                    
                }
                
                if mapPoint.y > upperRightCorner.y {
                    
                    upperRightCorner.y = mapPoint.y
                    
                }
                
                if mapPoint.x < lowerLeftCorner.x {
                    
                    lowerLeftCorner.x = mapPoint.x
                    
                }
                
                if mapPoint.y < lowerLeftCorner.y {
                    
                    lowerLeftCorner.y = mapPoint.y
                    
                }
                
            }
            
            // Append the new mapPoint into arrayOfMapPoints
            
            arrayOfMapPoints.append(mapPoint)
            
        }
        
        
        
        // Create the tripTrack as a polyline using the arrayOfMapPoints.
        
        // Pass by Reference: The object reference of arrayOfMapPoints is passed using the & operator.
        
        tripTrack = MKPolyline(points: &arrayOfMapPoints, count: numberOfWaypoints)
        
        
        
        // Compute a box to bound all of the tracks so that we can zoom in on it.
        
        let width:  Double = upperRightCorner.x - lowerLeftCorner.x
        
        let height: Double = upperRightCorner.y - lowerLeftCorner.y
        
        
        
        trackBoundingBox = MKMapRectMake(lowerLeftCorner.x, lowerLeftCorner.y, width, height)
        
    }
    
    
    
    /*
     
     ------------------------------------------
     
     MARK: - MKMapViewDelegate Protocol Methods
     
     ------------------------------------------
     
     */
    
    
    
    /*
     
     "Asks the delegate for a renderer object to use when drawing the specified overlay.
     
     mapView = The map view that requested the renderer object.
     
     overlay = The overlay object that is about to be displayed.
     
     Returns = The renderer to use when presenting the specified overlay on the map." [Apple]
     
     */
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        
        var polylineRenderer: MKPolylineRenderer?
        
        
        
        if overlay is MKPolyline {
            
            
            
            if tripTrackRenderer == nil {
                
                
                
                tripTrackRenderer = MKPolylineRenderer(overlay: overlay)
                
                tripTrackRenderer?.fillColor = .red
                
                tripTrackRenderer?.strokeColor = .red
                
                tripTrackRenderer?.lineWidth = 3
                
            }
            
            
            
            polylineRenderer = tripTrackRenderer
            
        }
        
        return polylineRenderer!
        
    }
    
    
    
    /*
     
     "Returns the view associated with the specified annotation object.
     
     mapView    = The map view that requested the annotation view.
     
     annotation = The object representing the annotation that is about to be displayed.
     
     Returns    = The annotation view to display for the specified annotation" [Apple]
     
     */
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "WaypointInfo")
        
        
        
        pinAnnotationView.animatesDrop = true
        
        pinAnnotationView.canShowCallout = true
        
        pinAnnotationView.pinTintColor = UIColor.green
        
        
        
        return pinAnnotationView
        
    }
    
    
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        
        
        showErrorMessage(title: "Unable to Load Map!", message: "Problem Description: \(error.localizedDescription)")
        
        
        
    }
    
    
    
    /*
     
     -----------------------------
     
     MARK: - Display Error Message
     
     -----------------------------
     
     */
    
    
    
    func showErrorMessage(title errorTitle: String, message errorMessage: String) {
        
        
        
        /*
         
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         
         and store its object reference into local constant alertController
         
         */
        
        let alertController = UIAlertController(title: "\(errorTitle)",
                                                
                                                message: "\(errorMessage)",
                                                
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        
        
        // Create a UIAlertAction object and add it to the alert controller
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        
        
        // Present the alert controller
        
        present(alertController, animated: true, completion: nil)
        
    }


}
