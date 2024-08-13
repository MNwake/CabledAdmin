//
//  CarrierViewModel.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/11/24.
//

import Foundation

final class CarrierViewModel: ObservableObject {
    @Published var carrier: ContestCarrier
    var rider: Rider?
    
    init(carrier: ContestCarrier) {
        self.carrier = carrier
        // Initialize rider based on carrier's rider_id
    }
}
