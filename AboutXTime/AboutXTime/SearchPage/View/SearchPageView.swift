//
//  SearchPageView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/19.
//

import SwiftUI

struct SearchPageView: View {
    let capsules: [Capsule]
    @StateObject private var viewModel: SearchViewModel
    let userBirthDate: Date

    init(capsules: [Capsule], userBirthDate: Date) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(capsules: capsules, userBirthDate: userBirthDate))
        self.capsules = capsules
        self.userBirthDate = userBirthDate
    }

    var body: some View {
        VStack {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(STColor.C1.color.opacity(1),
                                lineWidth: 1)

                    HStack {
                        TextField("想找什麼？ 輸入膠囊內容、日期、圖片、心情狀態...", text: $viewModel.searchText, onCommit: {
                            viewModel.searchCapsules()
                        })
                        .padding(10)
                        .foregroundColor(Color.white)
                        .font(.caption)

                        Spacer()

                        Button(action: {
                            viewModel.searchText = ""
                            viewModel.searchCapsules()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.5))
                        }

                        Spacer()
                    }

                }
                .frame(height: 40)
                .padding(.leading, 40)

                Button(action: {
                    viewModel.searchCapsules()
                    hideKeyboard()
                }) {
                    Image(systemName: "magnifyingglass")
                        .background(.black)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding()
            }

            if !viewModel.filteredCapsules.isEmpty {
                List {
                    let sortedAges = viewModel.filteredCapsules.keys.sorted(by: >)
                    ForEach(sortedAges.indices, id: \.self) { index in
                        let age = sortedAges[index]
                        if let capsulesForAge = viewModel.filteredCapsules[age], !capsulesForAge.isEmpty {
                            capsuleAgeSection(sectionIndex: index, age: age, capsules: capsulesForAge)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 200)
                }
            } else {
                //                Spacer()
                Text("""

                .     .       .
   *      .  . .        .         .
                *    *   .     .         *
   .      .   *    .     .       .
             *   .   ***       .
  *    .     *****     *    .         *
     .    --------------------  .      .
. **      | No results found |.  .  ***
    .     ====================
            .  *****  .   .      *
   *   .     *******     *    .       .
        *     *****   *    .      .
            .  *****     .
                *****   *       *
                *****      .
                 ***   *    .
                  *       .
                /\\\\__/\\\\
               ( o.o )
               > ^ <   ~~
   ~~~~~~~~~~~~~~~~~~~~~
   |   |   |   |   |   |   |   |   |   |   |   |   |
   |   |   |   |   |   |   |   |   |   |   |   |   |
   |   |   |   |   |   |   |   |   |   |   |   |   |
""")
                .foregroundColor(.gray)
                .padding(.horizontal)
                Spacer()
            }
        }
        .background(Color.black)
    }

    @ViewBuilder
    func capsuleAgeSection(sectionIndex: Int, age: Int, capsules: [Capsule]) -> some View {
        Section(header: sectionHeader(forAge: age, sectionIndex: sectionIndex)) {

            let sortedCapsules = capsules.sorted(by: { $0.openDate > $1.openDate })

            ForEach(sortedCapsules) { capsule in
                NavigationLink(destination: ShowCapsulePageRepresentable(
                    capsule: capsule,
                    isPresented: .constant(true)).ignoresSafeArea(.all)) {
                        HStack(alignment: .top) {
                            Image("planet\(min(sectionIndex + 1, 18))")
                            .resizable()
                            .frame(width: 30, height: 30)

                        VStack(alignment: .leading) {
                            Text("第 \(calculateWeekForUserAtAge(capsule: capsule, userBirthDate: userBirthDate)) 週")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("開啟日期: \(formatDate(date: capsule.openDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color.black)
            }
            .onDelete { indexSet in
                deleteCapsule(at: indexSet, for: age, in: sortedCapsules)
            }
        }
    }

    private func sectionHeader(forAge age: Int, sectionIndex: Int) -> some View {
        HStack {
            Text(" \(age) 歲")
                .font(.title)
                .bold()
                .foregroundColor(.white)
        }
    }

    func calculateWeekForUserAtAge(capsule: Capsule, userBirthDate: Date) -> (Int) {
        let calendar = Calendar.current

        let ageAtCapsuleOpen = calendar.dateComponents([.year], from: userBirthDate, to: capsule.openDate).year ?? 0

        let birthdayThisYear = calendar.date(byAdding: .year, value: ageAtCapsuleOpen,
                                             to: userBirthDate) ?? userBirthDate

        let weeksSinceBirthday = calendar.dateComponents([.weekOfYear],
                                                         from: birthdayThisYear,
                                                         to: capsule.openDate).weekOfYear ?? 1

        return (weeksSinceBirthday - 1) % 52 + 1
    }

    // 刪除膠囊
    private func deleteCapsule(at indexSet: IndexSet, for age: Int, in capsules: [Capsule]) {
        guard let index = indexSet.first,
              let _ = viewModel.filteredCapsules[age] else { return }

        let capsuleToDelete = capsules[index]

        if var capsulesForAge = viewModel.filteredCapsules[age] {
            if let localIndex = capsulesForAge.firstIndex(where: { $0.id == capsuleToDelete.id }) {
                capsulesForAge.remove(at: localIndex)
                viewModel.filteredCapsules[age] = capsulesForAge.isEmpty ? nil : capsulesForAge
            }
        }

        FirebaseManager.shared.deleteCapsuleFromFirestore(capsuleId: capsuleToDelete.id)
    }
}
