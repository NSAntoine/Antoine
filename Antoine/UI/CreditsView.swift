//
//  CreditsView.swift
//  Antoine
//
//  Created by Serena on 11/02/2023.
//

import SwiftUI

struct CreditsView: View {
    @State var people: [CreditsPerson] = []
    @State var madokaHomuraGifImg: GIFImage? = nil
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var body: some View {
        List {
            VStack(alignment: .center) {
                madokaHomuraGifImg?
                    .frame(width: UIScreen.main.bounds.width, height: 200)
            }
            .listRowBackground(Color.clear)
            
            ForEach(people, id: \.self) { person in
                CreditsPersonView(person: person)
                    .onTapGesture {
                        UIApplication.shared.open(person.socialLink)
                    }
            }
        }
        
        .onAppear {
            people = CreditsPerson.allContributors
            URLSession.shared.dataTask(with: URL(string: "https://gist.githubusercontent.com/SerenaKit/54ce265a45a8281ffb76b20b7c6ea53c/raw/4939dabe5c7713a709dda3efeed22428b655400e/anime-madoka.gif")!) { data, response, error in
                if let data {
                    madokaHomuraGifImg = GIFImage(data: data)
                }
            }
            .resume()
        }
        .navigationBarTitle("Credits")
    }
}

struct CreditsPersonView: View {
    var person: CreditsPerson
    @State var img = Image(systemName: "person.circle")
    var body: some View {
        HStack {
            img
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(person.name)
                    .font(.system(size: 17, weight: .semibold))
                Text(person.role)
                    .font(.subheadline)
            }
        }
        .onAppear {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: person.pfpURL),
                    let uiImage = UIImage(data: data) {
                    self.img = Image(uiImage: uiImage)
                }
            }
        }
    }
}
