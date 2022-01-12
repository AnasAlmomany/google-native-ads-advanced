//
//  ADSProvider.swift
//  BannerTableViewExample
//
//  Created by Anas Almomany on 10/01/2022.
//  Copyright © 2022 Anas. All rights reserved.
//

import Foundation
import GoogleMobileAds

class ADSProvider: NSObject {
    struct NativeAd: Presentation {
        var gADNativeAd: GADNativeAd
    }

    unowned var rootViewController: UIViewController
    unowned var tableView: UITableView

    private let adUnitID = "ca-app-pub-3940256099942544/3986624511"
    private let numAdsToLoad = 5
    private var nativeAds = [NativeAd]()
    private var adLoader: GADAdLoader!
    private var adInsertionEvery = 2

    var adsDictionary: [IndexPath: NativeAd] = [:]
    var completion: (([NativeAd])->())? = nil

    var insertionOperation: ((ADSProvider.NativeAd, Int)->())? = nil

    init(rootViewController: UIViewController, tableView: UITableView, adInsertionEvery number: Int = 2) {
        self.adInsertionEvery = number
        self.tableView = tableView
        self.rootViewController = rootViewController
        super.init()

        tableView.register(UINib(nibName: "UnifiedNativeAdCell", bundle: nil),
                           forCellReuseIdentifier: "UnifiedNativeAdCell")

        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: rootViewController,
                               adTypes: [GADAdLoaderAdType.native],
                               options: [options])
        adLoader.load(GADRequest())
        adLoader.delegate = self
    }

    func heightForAd(at index: IndexPath) -> CGFloat? {
        (adsDictionary[index]?.gADNativeAd == nil) ? nil : 400
    }

    func adForRowAr(indexPath: IndexPath) -> UITableViewCell? {
        if let nativeAd = adsDictionary[indexPath]?.gADNativeAd {
            nativeAd.rootViewController = rootViewController
            let nativeAdCell = tableView.dequeueReusableCell(withIdentifier: "UnifiedNativeAdCell", for: indexPath)
            let adView: GADNativeAdView = nativeAdCell.contentView.subviews.first?.subviews.first as! GADNativeAdView
            adView.nativeAd = nativeAd
            // Populate the ad view with the ad assets.
            (adView.headlineView as! UILabel).text = nativeAd.headline
            (adView.priceView as! UILabel).text = nativeAd.price
            if let starRating = nativeAd.starRating {
                (adView.starRatingView as! UILabel).text =
                starRating.description + "\u{2605}"
            } else {
                (adView.starRatingView as! UILabel).text = nil
            }
            (adView.bodyView as! UILabel).text = nativeAd.body
            (adView.advertiserView as! UILabel).text = nativeAd.advertiser
            // The SDK automatically turns off user interaction for assets that are part of the ad, but
            // it is still good to be explicit.
            (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
            (adView.callToActionView as! UIButton).setTitle(
                nativeAd.callToAction, for: UIControl.State.normal)
            return nativeAdCell
        }

        return nil
    }
}

extension ADSProvider: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }

    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("Received native ad: \(nativeAd)")
        nativeAds.append(NativeAd(gADNativeAd: nativeAd))
    }

     func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
         var nativeAds = nativeAds
         stride(from: 1, to: nativeAds.count * adInsertionEvery + adInsertionEvery, by: adInsertionEvery).forEach { i in
             if let ad = nativeAds.popLast() {
                 self.adsDictionary[IndexPath(row: i, section: 0)] = ad
                 self.insertionOperation?(ad, i)
             }
         }

         tableView.reloadData()
     }
}
