require('es6-promise').polyfill()
global.chai = require 'chai'
global.expect = chai.expect
global.sinon = require 'sinon'
global.sandbox = sinon.sandbox.create()
global.sinonChai = require 'sinon-chai'
chai.use sinonChai

module.exports =
  runFor: ({StoreClass, options}) ->
    options ?= {}

    describe 'Eventric store', ->
      firstDomainEventFake = null
      secondDomainEventFake = null
      store = null

      beforeEach ->
        contextFake =
          name: 'contextFake'

        firstDomainEventFake =
          name: 'FirstEvent'
          aggregate:
            id: 42

        secondDomainEventFake =
          name: 'SecondEvent'
          aggregate:
            id: 43

        store = new StoreClass()
        store.initialize contextFake, options


      describe '#saveDomainEvent', ->

        it 'should save the domain event', ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.findDomainEventsByName firstDomainEventFake.name, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 1
              expect(domainEvents[0].name).to.equal firstDomainEventFake.name


        it 'should resolve with the saved domain event', ->
          store.saveDomainEvent firstDomainEventFake
          .then (savedDomainEvent) ->
            expect(savedDomainEvent).to.be.ok


        it 'should assign an ascending integer as id', ->
          store.saveDomainEvent firstDomainEventFake
          .then (savedDomainEvent) ->
            expect(savedDomainEvent.id).to.equal 1


        it 'should assign an ascending integer as id to each saved domain in correct order', ->
          thirdDomainEventFake =
            name: 'ThirdEvent'
            aggregate:
              id: 44
          store.saveDomainEvent firstDomainEventFake
          .then (firstDomainEvent) ->
            store.saveDomainEvent secondDomainEventFake
            .then (secondDomainEvent) ->
              store.saveDomainEvent thirdDomainEventFake
              .then (thirdDomainEvent) ->
                expect(firstDomainEvent.id).to.equal 1
                expect(secondDomainEvent.id).to.equal 2
                expect(thirdDomainEvent.id).to.equal 3


      describe '#findDomainEventsByName', ->

        it 'should call back with domain events with matching name', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.findDomainEventsByName firstDomainEventFake.name, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 1
              expect(domainEvents[0].name).to.equal firstDomainEventFake.name
              done()
          .catch done
          return


        it 'should call back without domain events with another name', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.findDomainEventsByName secondDomainEventFake.name, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 0
              done()
          .catch done
          return


        it 'should call back with domain events matching any name given an array of names', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.saveDomainEvent secondDomainEventFake
          .then ->
            store.findDomainEventsByName [firstDomainEventFake.name, secondDomainEventFake.name], (error, domainEvents) ->
              expect(domainEvents.length).to.equal 2
              expect(domainEvents[0].name).to.equal firstDomainEventFake.name
              expect(domainEvents[1].name).to.equal secondDomainEventFake.name
              done()
          .catch done
          return


      describe '#findDomainEventsByAggregateId', ->

        it 'should call back with domain events with matching aggregate id', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.findDomainEventsByAggregateId firstDomainEventFake.aggregate.id, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 1
              expect(domainEvents[0].name).to.equal firstDomainEventFake.name
              done()
          .catch done
          return


        it 'should call back without domain events with another aggregate id', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.findDomainEventsByAggregateId secondDomainEventFake.aggregate.id, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 0
              done()
          .catch done
          return


        it 'should call back with domain events matching any aggregrate id given an array of aggregate ids', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.saveDomainEvent secondDomainEventFake
          .then ->
            store.findDomainEventsByAggregateId [firstDomainEventFake.aggregate.id, secondDomainEventFake.aggregate.id],
              (error, domainEvents) ->
                expect(domainEvents.length).to.equal 2
                expect(domainEvents[0].name).to.equal firstDomainEventFake.name
                expect(domainEvents[1].name).to.equal secondDomainEventFake.name
                done()
          .catch done
          return


      describe '#findDomainEventsByNameAndAggregateId', ->

        it 'should call back with domain events with a matching aggregate id and a matching name', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.findDomainEventsByNameAndAggregateId firstDomainEventFake.name,
              firstDomainEventFake.aggregate.id, (error, domainEvents) ->
                expect(domainEvents.length).to.equal 1
                expect(domainEvents[0].name).to.equal firstDomainEventFake.name
                done()
          .catch done
          return


        it 'should call back without domain events with another aggregate id or name', (done) ->
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.saveDomainEvent secondDomainEventFake
          .then ->
            store.findDomainEventsByNameAndAggregateId firstDomainEventFake.name,
              secondDomainEventFake.aggregate.id, (error, domainEvents) ->
                expect(domainEvents.length).to.equal 0
                done()
          .catch done
          return


        it 'should call back with all domain events matching any name and the aggregate id given an array of names', (done) ->
          secondDomainEventFake.aggregate.id = 42
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.saveDomainEvent secondDomainEventFake
          .then ->
            store.findDomainEventsByNameAndAggregateId [firstDomainEventFake.name, secondDomainEventFake.name],
              firstDomainEventFake.aggregate.id, (error, domainEvents) ->
                expect(domainEvents.length).to.equal 2
                expect(domainEvents[0].name).to.equal firstDomainEventFake.name
                expect(domainEvents[1].name).to.equal secondDomainEventFake.name
                done()
          .catch done
          return


        it 'should call back with all domain events matching the name and any aggregate id given an array of ids', (done) ->
          secondDomainEventFake.name = 'FirstEvent'
          store.saveDomainEvent firstDomainEventFake
          .then ->
            store.saveDomainEvent secondDomainEventFake
          .then ->
            store.findDomainEventsByNameAndAggregateId firstDomainEventFake.name,
              [firstDomainEventFake.aggregate.id, secondDomainEventFake.aggregate.id], (error, domainEvents) ->
                expect(domainEvents.length).to.equal 2
                expect(domainEvents[0].name).to.equal firstDomainEventFake.name
                expect(domainEvents[1].name).to.equal secondDomainEventFake.name
                done()
          .catch done
          return
