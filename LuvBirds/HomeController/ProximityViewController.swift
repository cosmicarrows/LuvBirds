//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

import EstimoteProximitySDK

struct Content {
    let title: String
    let subtitle: String
    let loveMessage: String
}

class ProximityViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var proximityObserver: ProximityObserver!
    
    var nearbyContent = [Content]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let estimoteCloudCredentials = CloudCredentials(appID: "luvbirds-iie", appToken: "36cb9c96f3aa67d5c248ec78d3be9894")
        
        proximityObserver = ProximityObserver(credentials: estimoteCloudCredentials, onError: { error in
            print("ProximityObserver error: \(error)")
        })
        
        let zone = ProximityZone(tag: "luvbirds-iie", range: ProximityRange.near)
        zone.onContextChange = { contexts in
            self.nearbyContent = contexts.map {
                return Content(title: $0.attachments["luvbirds-iie/title"]!, subtitle: $0.deviceIdentifier, loveMessage: $0.attachments["luvbirds-iie/lovemessage"]!)
            }
            
            self.collectionView?.reloadSections(IndexSet(integer: 0))
        }
        
        proximityObserver.startObserving([zone])
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyContent.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath)
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let subtitleLabel = cell.viewWithTag(2) as! UILabel
        let loveMessageLabel = cell.viewWithTag(45) as! UILabel
        
        let title = nearbyContent[indexPath.item].title
        let subtitle = nearbyContent[indexPath.item].subtitle
        let loveMessage = nearbyContent[indexPath.item].loveMessage
        
        
        
        cell.backgroundColor = Utils.color(forColorName: title)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        loveMessageLabel.text = loveMessage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = collectionView.frame.width - 20
        let maxHeight = collectionView.frame.height - (collectionView.layoutMargins.top + collectionView.layoutMargins.bottom)
        let singleCellHeight = maxHeight / CGFloat(nearbyContent.count) - (collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing
        
        return CGSize(width: maxWidth, height: singleCellHeight)
    }
    
    
}
